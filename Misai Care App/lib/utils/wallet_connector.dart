import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:misai_care/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'wallet_storage_manager.dart';

class WalletConnector {
  late final Web3App wcClient;
  String? _walletAddress;
  String? _did;
  String? _abhaNumber;
  Map<String, dynamic>? _userProfile;
  bool _isConnected = false;
  Timer? _timeoutTimer;
  Completer<SessionConnect>? _completer;

  // Getters
  String? get walletAddress => _walletAddress;
  String? get did => _did;
  String? get abhaNumber => _abhaNumber;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isConnected => _isConnected;

  // Initialize - check if wallet is already connected
  Future<bool> initialize() async {
    try {
      // Initialize WalletConnect client first
      await _initializeWalletConnect();
      
      final storedInfo = await WalletStorageManager.getStoredWalletInfo();

      if (storedInfo != null) {
        _walletAddress = storedInfo['walletAddress'];
        _did = storedInfo['did'];
        _abhaNumber = storedInfo['abhaNumber'];
        _userProfile = storedInfo['userProfile'];
        _isConnected = true;

        debugPrint('✅ Wallet auto-restored from storage');
        debugPrint('Address: $_walletAddress');
        debugPrint('DID: $_did');
        debugPrint('ABHA: $_abhaNumber');

        return true;
      }
    } catch (e) {
      debugPrint('❌ Error initializing wallet: $e');
    }
    return false;
  }

  Future<void> _initializeWalletConnect() async {
    const projectId = '74d82ee73dfbaa535c0e8deed03aa7ec';

    wcClient = await Web3App.createInstance(
      projectId: projectId,
      metadata: const PairingMetadata(
        name: 'MisaiCare',
        description: 'ABHA-linked Wallet',
        url: 'https://example.com',
        icons: ['https://example.com/icon.png'],
        redirect: Redirect(
          native: 'misai_care://walletconnect',
          universal: 'https://example.com',
        ),
      ),
    );
  }

  Future<void> connectWallet({
    String? abhaNumber,
    Map<String, dynamic>? userProfile,
  }) async {
    try {
      // Initialize WalletConnect if not already done
      if (!_isWalletConnectInitialized()) {
        await _initializeWalletConnect();
      }

      // Check for existing sessions first
      final sessions = wcClient.sessions.getAll();
      if (sessions.isNotEmpty) {
        final existing = sessions.first;
        final accounts = existing.namespaces['eip155']?.accounts;
        if (accounts != null && accounts.isNotEmpty) {
          final full = accounts.first;
          _walletAddress = full.split(':').last;
          _did = 'did:ethr:$_walletAddress';
          _isConnected = true;

          await WalletStorageManager.storeWalletInfo(
            walletAddress: _walletAddress!,
            did: _did!,
            abhaNumber: abhaNumber ?? _abhaNumber ?? '',
            userProfile: userProfile ?? _userProfile,
          );

          debugPrint('✅ Using existing session');
          return;
        }
      }

      await _connectWithRetry();

      if (_walletAddress != null && _did != null) {
        await WalletStorageManager.storeWalletInfo(
          walletAddress: _walletAddress!,
          did: _did!,
          abhaNumber: abhaNumber ?? _abhaNumber ?? '',
          userProfile: userProfile ?? _userProfile,
        );

        _abhaNumber = abhaNumber ?? _abhaNumber;
        _userProfile = userProfile ?? _userProfile;
        _isConnected = true;

        debugPrint('✅ Wallet connected and stored successfully');
      }
    } catch (e) {
      debugPrint('❌ Error connecting wallet: $e');
      rethrow;
    }
  }

  bool _isWalletConnectInitialized() {
    try {
      // Try to access wcClient to see if it's initialized
      wcClient.sessions.getAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _connectWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔄 Connection attempt $attempt/$maxRetries');
        await _attemptConnection();
        return;
      } catch (e) {
        debugPrint('❌ Attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  Future<void> _attemptConnection() async {
    _completer = Completer<SessionConnect>();

    await _clearStuckSessions();

    // Updated required namespaces with proper chain support
    final response = await wcClient.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: ['eth_sendTransaction', 'personal_sign', 'eth_sign'],
          chains: ['eip155:1'], // Ethereum mainnet
          events: ['accountsChanged', 'chainChanged'],
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: ['eth_sendTransaction', 'personal_sign', 'eth_sign'],
          chains: ['eip155:137', 'eip155:56'], // Polygon, BSC
          events: ['accountsChanged', 'chainChanged'],
        ),
      },
    );

    final wcUri = response.uri;
    if (wcUri == null) {
      throw Exception('Failed to generate WalletConnect URI');
    }

    debugPrint('📋 WalletConnect URI generated: ${wcUri.toString()}');

    _setupListeners();

    bool launched = await _launchMetaMask(wcUri);
    if (!launched) {
      throw Exception('Failed to open MetaMask - please ensure MetaMask is installed');
    }

    // Wait for connection with timeout
    int timeoutSeconds = 60;
    _timeoutTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      timeoutSeconds -= 10;
      debugPrint('⏳ Waiting for connection... ${timeoutSeconds}s remaining');
      if (timeoutSeconds <= 0) {
        timer.cancel();
        if (!_completer!.isCompleted) {
          _completer!.completeError(
            TimeoutException('Connection timeout - please try again', Duration(seconds: 60)),
          );
        }
      }
    });

    try {
      final event = await _completer!.future;
      _processConnectionEvent(event);
    } finally {
      _cleanup();
    }
  }

  Future<void> _clearStuckSessions() async {
    try {
      // Clear unacknowledged sessions
      final sessions = wcClient.sessions.getAll();
      for (final session in sessions) {
        if (session.acknowledged == false) {
          debugPrint('🧹 Clearing unacknowledged session: ${session.topic}');
          await wcClient.disconnectSession(
            topic: session.topic,
            reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
          );
        }
      }

      // Clear inactive pairings
      final pairings = wcClient.pairings.getAll();
      for (final pairing in pairings) {
        if (!pairing.active) {
          debugPrint('🧹 Clearing inactive pairing: ${pairing.topic}');
          await wcClient.core.pairing.disconnect(topic: pairing.topic);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error clearing stuck sessions: $e');
    }
  }

    Future<Map<String, dynamic>> getCredentials() async {
    return {
      'walletAddress': _walletAddress,
      'did': _did,
      'abhaNumber': _abhaNumber,
      'userProfile': _userProfile,
      'isConnected': _isConnected,
    };
  }

 Future<List<HealthPlan>> getHealthPlans() async {
  try {
    // Dummy implementation - replace with actual blockchain call
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    // Return dummy data
    return [
      HealthPlan(
        id: 'plan_1',
        title: 'Basic Health Plan',
        description: 'Initial health recommendations',
        recommendations: [
          'Exercise 3 times per week',
          'Drink 2L of water daily',
          'Get 7-8 hours of sleep'
        ],
        created: DateTime.now().subtract(const Duration(days: 30)),
      ),
      HealthPlan(
        id: 'plan_2',
        title: 'Advanced Health Plan',
        description: 'Updated recommendations based on your survey',
        recommendations: [
          'Increase cardio exercises',
          'Reduce sugar intake',
          'Annual health checkup'
        ],
        created: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
    
    // Actual implementation would look like:
    /*
    final contract = await _getHealthPlanContract();
    final plans = await contract.query(
      'getHealthPlans', 
      [EthereumAddress.fromHex(walletAddress)]
    );
    
    if (plans != null && plans is List) {
      return plans.map((p) => HealthPlan.fromJson(jsonDecode(p))).toList();
    }
    return [];
    */
    
  } catch (e) {
    debugPrint('Error fetching health plans: $e');
    return [];
  }
}

Future<void> saveHealthPlan(HealthPlan plan) async {
  try {
    // Dummy implementation - replace with actual blockchain call
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    debugPrint('Successfully saved plan: ${plan.id}');
    
    // Actual implementation would look like:
    /*
    final contract = await _getHealthPlanContract();
    final credentials = await _getCredentials();
    final function = contract.function('addHealthPlan');
    
    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          jsonEncode(plan.toJson()),
          EthereumAddress.fromHex(walletAddress)
        ],
      ),
    );
    */
    
  } catch (e) {
    debugPrint('Error saving health plan: $e');
    throw Exception('Failed to save health plan: $e');
  }
}

  Future<bool> _launchMetaMask(Uri wcUri) async {
    final encodedUri = Uri.encodeComponent(wcUri.toString());

    final launchStrategies = [
      'https://metamask.app.link/wc?uri=$encodedUri',
      'metamask://wc?uri=$encodedUri',
      'https://metamask.app.link/connect?uri=$encodedUri',
    ];

    for (int i = 0; i < launchStrategies.length; i++) {
      final scheme = launchStrategies[i];
      try {
        debugPrint(' Trying launch strategy ${i + 1}: $scheme');
        
        final launched = await launchUrl(
          Uri.parse(scheme),
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          debugPrint(' Successfully launched MetaMask');
          return true;
        }
      } catch (e) {
        debugPrint(' Launch strategy ${i + 1} failed: $e');
      }
    }

    try {
      debugPrint(' Trying fallback: launching MetaMask directly');
      final launched = await launchUrl(
        Uri.parse('metamask://'),
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        debugPrint(' MetaMask launched, but you need to manually connect');
        debugPrint(' WalletConnect URI: ${wcUri.toString()}');
        return true;
      }
    } catch (e) {
      debugPrint(' Fallback launch failed: $e');
    }

    return false;
  }

  void _setupListeners() {
    wcClient.onSessionConnect.subscribe(_onSessionConnect);
    wcClient.onSessionDelete.subscribe(_onSessionDelete);
    wcClient.onSessionExpire.subscribe(_onSessionExpire);
    wcClient.onSessionEvent.subscribe(_onSessionEvent);
  }

  void _onSessionConnect(SessionConnect? event) {
    debugPrint(' Session connect event received');
    if (event != null && _completer != null && !_completer!.isCompleted) {
      _completer!.complete(event);
    }
  }

  void _onSessionDelete(SessionDelete? event) {
    debugPrint('Session delete event received');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(Exception('Session deleted by user'));
    }
  }

  void _onSessionExpire(SessionExpire? event) {
    debugPrint(' Session expire event received');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(Exception('Session expired'));
    }
  }

  void _onSessionEvent(SessionEvent? event) {
    debugPrint(' Session event received: ${event?.name}');
  }

  void _processConnectionEvent(SessionConnect event) {
    final accounts = event.session.namespaces['eip155']?.accounts;
    if (accounts == null || accounts.isEmpty) {
      throw Exception('No wallet accounts returned');
    }
    
    final fullAddress = accounts.first;
    _walletAddress = fullAddress.split(':').last;
    _did = 'did:ethr:$_walletAddress';
    
    debugPrint(' Connection successful');
    debugPrint(' Wallet Address: $_walletAddress');
    debugPrint(' DID: $_did');
  }

  void _cleanup() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    try {
      wcClient.onSessionConnect.unsubscribe(_onSessionConnect);
      wcClient.onSessionDelete.unsubscribe(_onSessionDelete);
      wcClient.onSessionExpire.unsubscribe(_onSessionExpire);
      wcClient.onSessionEvent.unsubscribe(_onSessionEvent);
    } catch (e) {
      debugPrint(' Error during cleanup: $e');
    }
  }

  Future<void> disconnectWallet() async {
    try {
      await WalletStorageManager.clearWalletData();

      final sessions = wcClient.sessions.getAll();
      for (final session in sessions) {
        await wcClient.disconnectSession(
          topic: session.topic,
          reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
        );
      }

      _walletAddress = null;
      _did = null;
      _abhaNumber = null;
      _userProfile = null;
      _isConnected = false;

      debugPrint(' Wallet disconnected successfully');
    } catch (e) {
      debugPrint(' Error disconnecting wallet: $e');
    }
  }

  void dispose() {
    _cleanup();
    _completer = null;
  }

  Future<bool> checkMetaMaskAvailability() async {
    final schemes = [
      'metamask://',
      'https://metamask.app.link/',
    ];

    for (final scheme in schemes) {
      try {
        final canLaunch = await canLaunchUrl(Uri.parse(scheme));
        if (canLaunch) {
          debugPrint(' MetaMask is available via: $scheme');
          return true;
        }
      } catch (e) {
        debugPrint(' Cannot launch $scheme: $e');
      }
    }
    
    debugPrint(' MetaMask not available - please install MetaMask');
    return false;
  }

  Future<void> forceDisconnectAll() async {
    try {
      final sessions = wcClient.sessions.getAll();
      for (final session in sessions) {
        await wcClient.disconnectSession(
          topic: session.topic,
          reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
        );
      }

      final pairings = wcClient.pairings.getAll();
      for (final pairing in pairings) {
        await wcClient.core.pairing.disconnect(topic: pairing.topic);
      }
      
      debugPrint('✅ All sessions and pairings disconnected');
    } catch (e) {
      debugPrint('❌ Error force disconnecting: $e');
    }
  }


  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected,
      'walletAddress': _walletAddress,
      'did': _did,
      'abhaNumber': _abhaNumber,
      'activeSessions': wcClient.sessions.getAll().length,
      'activePairings': wcClient.pairings.getAll().length,
    };
  }
}