import 'dart:math' as math;
import 'package:misai_care/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/wallet_storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:misai_care/utils/wallet_connector.dart';



class CongratsPopup extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final Animation<double> rotationAnimation; 
  final VoidCallback onComplete;

  const CongratsPopup({
    super.key,
    required this.animationController,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.rotationAnimation,
    required this.onComplete,
  });

  @override
  State<CongratsPopup> createState() => _CongratsPopupState();
}

class _CongratsPopupState extends State<CongratsPopup>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final List<ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    _setupConfettiAnimation();
    _generateConfetti();
  }

  void _setupConfettiAnimation() {
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _confettiController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(
        ConfettiParticle(
          x: random.nextDouble() * 400,
          y: random.nextDouble() * 800,
          color: _getRandomColor(),
          size: random.nextDouble() * 8 + 4,
          rotation: random.nextDouble() * 2 * math.pi,
          rotationSpeed: random.nextDouble() * 0.1 + 0.05,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: widget.animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // ❌ No background dark overlay here

              // 🎉 Confetti particles
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(
                      _confettiParticles,
                      _confettiController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

              // 🎉 Main popup
              Center(
                child: Transform.scale(
                  scale: widget.scaleAnimation.value,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 300,
                          height: 350,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFFD700), 
                                Color(0xFFFF8C00), 
                                Color(0xFFFF69B4), 
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.military_tech,
                              size: 80,
                              color: Colors.white, 
                            ),
                          ),
                              const SizedBox(height: 20),
                              const Text(
                                'Congratulations!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                              const SizedBox(height: 10),

                              const Text(
                                'Misai Account',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              const Text(
                                'Created Successfully!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(height: 15),

                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4CAF50)
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(height: 20),

                              const Text(
                                'Your digital health identity is now ready!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationValue;

  ConfettiPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;

      canvas.save();
      canvas.translate(particle.x, particle.y - (animationValue * 200));
      canvas.rotate(
        particle.rotation + (animationValue * particle.rotationSpeed * 10),
      );

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OtpVerificationScreen extends StatefulWidget {
  final String txnId;
  final String mobile;

  const OtpVerificationScreen({
    super.key,
    required this.txnId,
    required this.mobile,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
  with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final TextEditingController _hiddenController = TextEditingController();
  final FocusNode _hiddenFocusNode = FocusNode();
  
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _error;
  Map<String, dynamic>? accountData;
  
  Timer? _resendTimer;
  int _resendCountdown = 30;
  bool _canResend = false;
  bool _checkingWallet = true;

  
  late AnimationController _shakeController;
  late AnimationController _successController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successAnimation;
  late AnimationController _congratsController;
  late Animation<double> _congratsScaleAnimation;
  late Animation<double> _congratsOpacityAnimation;
  late Animation<double> _congratsRotationAnimation;
  bool _isWalletRestored = false;
  late WalletConnector _walletConnector;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _setupAnimations();
    _setupAutoFill();    
    _walletConnector = WalletConnector();
   _checkWalletAndNavigate(); 
   _initializeWalletCheck();
  }

  Future<void> _checkWalletAndNavigate() async {
    try {
      final isRestored = await _walletConnector.initialize();
      
      if (isRestored && mounted) {
        accountData = {
          'ABHANumber': _walletConnector.abhaNumber,
          'name': _walletConnector.userProfile?['name'],
          'profilePhoto': _walletConnector.userProfile?['profilePhoto'],
          'preferredAbhaAddress': _walletConnector.userProfile?['preferredAbhaAddress'],
          'dob': _walletConnector.userProfile?['dob'],
          'gender': _walletConnector.userProfile?['gender'],
        };

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToDashboard();
        });
      }
    } catch (e) {
      debugPrint('Wallet check error: $e');
    } finally {
      if (mounted) {
        setState(() => _checkingWallet = false);
      }
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    
    if (_walletConnector.walletAddress == null || 
        _walletConnector.did == null || 
        accountData == null) {
      return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          walletAddress: _walletConnector.walletAddress!,
          did: _walletConnector.did!,
          abhaData: accountData!,
        ),
      ),
    );
  }


 Future<void> _initializeWalletCheck() async {
  try {
    final isWalletConnected = await _walletConnector.initialize();
    
    if (isWalletConnected && 
        _walletConnector.did != null && 
        _walletConnector.did!.isNotEmpty) {
      
      accountData = {
        'ABHANumber': _walletConnector.abhaNumber,
        'name': _walletConnector.userProfile?['name'],
        'profilePhoto': _walletConnector.userProfile?['profilePhoto'],
        'preferredAbhaAddress': _walletConnector.userProfile?['preferredAbhaAddress'],
        'dob': _walletConnector.userProfile?['dob'],
        'gender': _walletConnector.userProfile?['gender'],
      };

      if (mounted) {
        setState(() {
          _isWalletRestored = true;
          _isVerified = true;
        });
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToDashboard();
        });
      }
      return; 
    }
  } catch (e) {
    debugPrint('Wallet check error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallet check failed: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _checkingWallet = false);
    }
    
    if (!_isWalletRestored && mounted) {
      _startResendTimer();
      _setupAutoFill();
    }
  }
}
 void _setupAnimations() {
  _shakeController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  
  _successController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );

  _congratsController = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );
  
  _shakeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _shakeController,
    curve: Curves.elasticIn,
  ));
  
  _successAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _successController,
    curve: Curves.bounceOut,
  ));

  // NEW: Add congratulations animations
  _congratsScaleAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _congratsController,
    curve: Curves.elasticOut,
  ));

  _congratsOpacityAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _congratsController,
    curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
  ));

  _congratsRotationAnimation = Tween<double>(
    begin: 0.0,
    end: 2 * math.pi,
  ).animate(CurvedAnimation(
    parent: _congratsController,
    curve: Curves.easeInOut,
  ));
}

  void _setupAutoFill() {
    _hiddenController.addListener(() {
      String text = _hiddenController.text;
      if (text.length <= 6 && text.isNotEmpty) {
        _fillOtpFields(text);
      }
    });

    SystemChannels.textInput.invokeMethod('TextInput.requestAutofill');
  }

  void _showCongratsPopup() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CongratsPopup(
      animationController: _congratsController,
      scaleAnimation: _congratsScaleAnimation,
      opacityAnimation: _congratsOpacityAnimation,
      rotationAnimation: _congratsRotationAnimation,
      onComplete: () {
        Navigator.of(context).pop();
      },
    ),
  );
  
  _congratsController.forward();
}

  void _fillOtpFields(String otp) {
    setState(() {
      _error = null;
    });
    
    for (int i = 0; i < 6; i++) {
      if (i < otp.length) {
        _otpControllers[i].text = otp[i];
      } else {
        _otpControllers[i].clear();
      }
    }
    
    if (otp.length == 6) {
      for (var node in _focusNodes) {
        node.unfocus();
      }
      _hiddenFocusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 100), () {
        _verifyOtp();
      });
    }
  }

  

  void _startResendTimer() {
    _resendCountdown = 30;
    _canResend = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _shakeController.dispose();
    _successController.dispose();
    _hiddenController.dispose();
    _congratsController.dispose(); 
    _hiddenFocusNode.dispose();
    
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((controller) => controller.text).join();

  void _onOtpChanged(String value, int index) {
    setState(() {
      _error = null;
    });

    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) {
          _verifyOtp();
        }
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

 Future<void> _verifyOtp() async {
  final otp = _otpCode;

  if (otp.length != 6) {
    setState(() {
      _error = 'Please enter complete 6-digit OTP';
    });
    _shakeController.forward().then((_) => _shakeController.reverse());
    return;
  }

  setState(() {
    _isVerifying = true;
    _error = null;
  });

  final url = 'http://192.168.5.162:5000/api/abha/login/verify';
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({'txnId': widget.txnId, 'otp': otp});

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final message = data['message'];

      if (data['accounts'] != null && data['accounts'].isNotEmpty) {
        setState(() {
          accountData = data['accounts'][0];
          _isVerified = true;
        });

        _successController.forward();

        await _walletConnector.connectWallet(
          abhaNumber: accountData?['ABHANumber'] ?? '',
          userProfile: accountData,
        );

        final bool hasDID = _walletConnector.did != null && _walletConnector.did!.isNotEmpty;
        
        if (hasDID) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Redirecting to dashboard...'),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          
          await Future.delayed(const Duration(milliseconds: 500));
          _navigateToDashboard();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(message),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          
          _showCongratsPopup();
          
          Future.delayed(const Duration(seconds: 3), () {
            _navigateToDashboard();
          });
        }
      }
    } else {
      setState(() {
        _error = 'Invalid OTP. Please try again.';
      });
      _shakeController.forward().then((_) => _shakeController.reverse());
      _clearOtpFields();
    }
  } catch (e) {
    setState(() {
      _error = 'Connection error. Please check your internet.';
    });
    _shakeController.forward().then((_) => _shakeController.reverse());
  } finally { 
    setState(() {
      _isVerifying = false;
    });
  }
}
 
 
  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully!'),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    _startResendTimer();
  }

  Widget _buildOtpInput(int index) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 10 * (index % 2 == 0 ? 1 : -1), 0),
          child: Container(
            width: 45,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _error != null
                    ? Colors.red.shade300
                    : _otpControllers[index].text.isNotEmpty 
                        ? const Color.fromARGB(255, 250, 250, 250)
                        : Colors.grey.shade300,
                width: 2,
              ),
              color: _otpControllers[index].text.isNotEmpty 
                  ? const Color(0xFF4CAF50).withOpacity(0.05)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              maxLength: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => _onOtpChanged(value, index),
            ),
          ),
        );
      },
    );
  }

   Widget _buildAbhaCard(Map<String, dynamic> account) {
    String? base64Image = account['profilePhoto'];
    String abhaNumber = account['ABHANumber'] ?? '';
    String formattedAbhaNumber = abhaNumber.length >= 14
        ? '${abhaNumber.substring(0, 2)}-${abhaNumber.substring(2, 6)}-${abhaNumber.substring(6, 10)}-${abhaNumber.substring(10, 14)}'
        : abhaNumber;

    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _successAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(top: 32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF1565C0),
                      Color(0xFF0D47A1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'lib/assets/images/image.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ABHA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Health ID',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'lib/assets/images/MisaiCare.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 90,
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                color: Colors.grey.shade50,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: base64Image != null && base64Image.isNotEmpty
                                    ? Image.memory(
                                        base64Decode(base64Image),
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 45,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _detailRow('Name', account['name'] ?? ''),
                          _detailRow('Health ID Number', formattedAbhaNumber),
                          _detailRow('PHR Address', account['preferredAbhaAddress'] ?? ''),
                          _detailRow('Date of Birth', account['dob'] ?? ''),
                          _detailRow('Gender', account['gender'] ?? ''),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Colors.grey, thickness: 0.4),
                          const SizedBox(height: 12),

                          // UPDATED: Wallet connection button
                          ElevatedButton.icon(
                            onPressed: _isWalletRestored ? null : () async {
                              try {
                                await _walletConnector.connectWallet(
                                  abhaNumber: accountData?['ABHANumber'] ?? '',
                                  userProfile: accountData,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Wallet Connected: ${_walletConnector.did}'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                
                                setState(() {
                                  _isWalletRestored = true;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Connection failed: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: Icon(_isWalletRestored ? Icons.check_circle : Icons.account_balance_wallet),
                            label: Text(_isWalletRestored ? "Wallet Connected" : "Connect MetaMask Wallet"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isWalletRestored 
                                  ? Colors.green 
                                  : const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'For representation purpose only',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<void> _disconnectWallet() async {
    await _walletConnector.disconnectWallet();
    setState(() {
      _isWalletRestored = false;
      accountData = null;
      _isVerified = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wallet disconnected successfully'),
        backgroundColor: Colors.orange,
      ),
    );
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // NEW: Wallet restoration indicator
          if (_isWalletRestored)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: SafeArea(
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Wallet restored from previous session',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      // Optional: Add disconnect button
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: _disconnectWallet,
                        tooltip: 'Disconnect wallet',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          // Existing hidden text field for auto-fill
          Positioned(
            left: -1000,
            top: -1000,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _hiddenController,
                focusNode: _hiddenFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofillHints: const [AutofillHints.oneTimeCode],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.transparent),
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: _isWalletRestored ? 80 : 24,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              children: [
                SizedBox(height: _isWalletRestored ? 20 : 80),
                if (!_isVerified) ...[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1976D2).withOpacity(0.1),
                          const Color(0xFF1976D2).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sms,
                      size: 50,
                      color: Color(0xFF5BCC6A),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Enter Verification Code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4D9E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'We sent a 6-digit code to\n'),
                        TextSpan(
                          text: '+91-${widget.mobile}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A4D9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Auto-fill trigger area
                  GestureDetector(
                    onTap: () {
                      _hiddenFocusNode.requestFocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            color: Color(0xFF1A4D9E),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tap here to auto-fill OTP from SMS',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A4D9E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: _buildOtpInput(index),
                  )),
                ),

                  if (_error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5BCC6A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: Text(
                      _canResend 
                          ? 'Didn\'t receive code? Resend'
                          : 'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                        color: _canResend ? const Color(0xFF1A4D9E) : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                
                if (accountData != null) _buildAbhaCard(accountData!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}