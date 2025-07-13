import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> 
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  bool _showQuickPrompts = true;
  
  // Voice recognition
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  
  // Text-to-speech
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  String? _currentSpeakingMessageId;
  bool _ttsEnabled = true;
  
  // Animation controllers
  late AnimationController _typingAnimationController;
  late AnimationController _slideAnimationController;
  
  // Custom colors
  static const Color primaryBlue = Color(0xFF1A4D9E);
  static const Color primaryGreen = Color(0xFF5BCC6A);
  
  // Quick prompts data
  final List<Map<String, String>> _quickPrompts = [
    {
      'icon': '🏥',
      'title': 'Health Insurance Queries',
      'description': 'Ask about health insurance plans, coverage, and benefits',
      'prompt': 'I need help with health insurance queries'
    },
    {
      'icon': '📋',
      'title': 'Registration Process',
      'description': 'Learn about the registration process and requirements',
      'prompt': 'Can you help me with the registration process?'
    },
    {
      'icon': '🆔',
      'title': 'ABHA Health ID',
      'description': 'Get information about ABHA Health ID creation and usage',
      'prompt': 'I need information about ABHA Health ID'
    },
    {
      'icon': '💊',
      'title': 'Policy and Claims',
      'description': 'Get guidance on policies and claims procedures',
      'prompt': 'I need help with policy and claims guidance'
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    
    // Initialize animation controllers
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _initializeTts();
    _initSpeech();
    _addWelcomeMessage();
    
    // Start animations
    _typingAnimationController.repeat();
    _slideAnimationController.forward();
  }
  
  void _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _currentSpeakingMessageId = null;
      });
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        _currentSpeakingMessageId = null;
      });
    });
  }
  
  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }
  
  Future<void> _addWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hello! I'm your Misaicare AI assistant. I'm here to help you with various health insurance and medical services.\n\nPlease choose from the options below or type your question:",
      isUser: false,
      timestamp: DateTime.now(),
      hasPrompts: true,
    );
    
    setState(() => _messages.add(welcomeMessage));
    _scrollToBottom();
    if (_ttsEnabled) {
      await _speak(welcomeMessage.text, welcomeMessage.id);
    }
  }
  
  void _handleQuickPrompt(String prompt) {
    setState(() {
      _showQuickPrompts = false;
    });
    
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    // Send to API
    _sendToAPI(prompt);
  }
  
  Future<void> _speak(String text, String messageId) async {
    if (text.isNotEmpty && !_isSpeaking && _ttsEnabled) {
      setState(() {
        _isSpeaking = true;
        _currentSpeakingMessageId = messageId;
      });
      await _flutterTts.speak(text);
    }
  }
  
  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _currentSpeakingMessageId = null;
    });
  }
  
  void _startListening() async {
    if (_speech.isAvailable) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (val) => setState(() {
          _lastWords = val.recognizedWords;
          if (val.finalResult && _lastWords.isNotEmpty) {
            _messageController.text = _lastWords;
            _sendMessage();
          }
        }),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      );
    }
  }

   final Map<String, String> _staticResponses = {
  'misai_blockchain': '''
Misai Insurance Automation with Blockchain

What is Misai?
Misai is a healthcare technology platform that uses blockchain to make insurance simpler, faster, and more secure.

How Blockchain Helps Insurance:

Traditional Problems:
- Slow claims (15-30 days)
- Lost documents
- Manual verification
- Fraud issues
- No transparency

Blockchain Solutions:
- Instant claims - Auto-processed in minutes
- Secure storage - Documents can't be lost
- Smart contracts - Automatic verification
- Fraud proof - Impossible to fake
- Full transparency - Track everything real-time

Misai Automation Features:

1. Smart Contracts
• Automatic claim processing
• No human intervention needed
• Instant approval/rejection
• Rule-based decisions

2. Digital Identity
• ABHA Health ID linked to blockchain
• One digital identity for all services
• Secure & private - you control access

3. Instant Verification
• Hospital network pre-verified
• Doctor credentials on blockchain
• Medicine authenticity checked
• Treatment history secure

4. Real-time Processing
• Hospital admits → Auto-notification
• Treatment done → Auto-bill generation
• Claim submitted → Auto-verification
• Payment released → Instant transfer

Benefits for You:
• Speed: Claims in minutes, not days
• Security: Blockchain protection
• Transparency: Track every step
• Cost: Lower processing fees
• Trust: No middleman needed

How It Works:
1. Visit hospital
2. Show digital ID
3. Treatment auto-recorded
4. Claim auto-processed
5. Payment instant

Ready to experience the future of insurance?
  ''',

  'abha_health_id': '''
ABHA Health ID - Your Digital Health Identity

What is ABHA?
ABHA (Ayushman Bharat Health Account) is a unique 14-digit health ID for every Indian citizen.

Key Benefits:
• One ID for all healthcare - Use across hospitals, clinics, labs
• Digital health records - All medical history in one place
• Secure & private - You control who sees your data
• Easy insurance claims - Link with health insurance
• Track health journey - Monitor your health progress

How to Create ABHA ID:
1. Visit: https://abha.abdm.gov.in
2. Choose Aadhaar or Mobile verification
3. Complete OTP verification
4. Set your ABHA address (like email)
5. Done! Your 14-digit ABHA ID is ready

Uses:
- Hospital registrations
- Lab test bookings
- Medicine purchases
- Telemedicine consultations
- Health insurance claims
- Vaccination records

Need help creating your ABHA ID? Just ask me!
  ''',

  'health_insurance': '''
Health Insurance Made Simple

What is Health Insurance?
Protection against medical expenses - pay small premium, get big coverage!

Key Benefits:
• Cashless treatment - No upfront payment at network hospitals
• Wide hospital network - 10,000+ hospitals across India
• Family coverage - Cover spouse, children, parents
• Emergency coverage - Ambulance, ICU, surgeries covered
• Medicine coverage - Prescribed medicines included

What's Covered:
- Hospitalization (24+ hours)
- Day-care procedures
- Pre & post hospitalization
- Ambulance charges
- Room rent & nursing
- Doctor's fees
- Diagnostic tests

Popular Plans:
• Individual: ₹3,000-₹15,000/year
• Family: ₹8,000-₹30,000/year
• Senior Citizen: ₹10,000-₹50,000/year

How to Buy:
1. Compare plans online
2. Choose coverage amount
3. Fill application form
4. Pay premium
5. Get policy document

Ready to secure your health? Let me help you choose!
  ''',

  'registration_process': '''
Easy Registration Process

Step-by-Step Registration:

1. Choose Your Plan
• Compare different insurance plans
• Select coverage amount (₹3L, ₹5L, ₹10L, etc.)
• Choose individual or family plan

2. Fill Application
• Personal details (Name, Age, Address)
• Health information
• Nominee details
• Upload documents

3. Required Documents
- Identity proof (Aadhaar/PAN/Passport)
- Address proof (Aadhaar/Utility bill)
- Age proof (Birth certificate/10th mark sheet)
- Income proof (Salary slip/ITR)
- Passport size photographs

4. Health Check-up
• Medical tests (if required)
• Based on age and coverage amount
• Usually for coverage above ₹5 lakhs

5. Premium Payment
• Online payment (UPI/Card/Net banking)
• Offline payment (Cheque/DD)
• EMI options available

6. Policy Issuance
• Instant policy for online purchases
• Policy document via email/SMS
• Physical copy if requested

Registration Time: 15-30 minutes online
Policy Starts: Immediately (some conditions apply)

Need help with registration? I'm here to guide you!
  ''',

  'policy_claims': '''
Policy & Claims Made Easy

How to Use Your Policy:

Cashless Treatment:
1. Go to network hospital
2. Show insurance card/policy
3. Fill pre-authorization form
4. Get approval from insurance company
5. Treatment without payment

Reimbursement Claims:
1. Pay hospital bills
2. Collect all documents
3. Submit claim within 30 days
4. Insurance company reviews
5. Get money back in 15-30 days

Documents for Claims:
- Claim form (filled & signed)
- Policy copy
- Hospital bills & receipts
- Doctor's prescription
- Diagnostic reports
- Discharge summary

Claim Process Time:
• Cashless: 2-6 hours approval
• Reimbursement: 15-30 days

Track Your Claim:
• Online portal/mobile app
• SMS updates
• Customer care helpline

Common Exclusions:
- Pre-existing diseases (first 2-4 years)
- Cosmetic surgeries
- Dental treatment (unless accidental)
- Maternity (waiting period applies)
- Self-inflicted injuries

Claim Rejected? Don't worry!
• Check rejection reason
• Provide additional documents
• Appeal if needed
• Contact ombudsman if required

Need help with your claim? I'm here to assist!
  '''
};

  // Check if message matches any quick response keywords
  String? _getStaticResponse(String message) {
    message = message.toLowerCase();
    
    // Misai blockchain related keywords
    if (message.contains('misai') || 
        message.contains('blockchain') || 
        message.contains('automate insurance') ||
        message.contains('smart contract') ||
        message.contains('instant claim')) {
      return _staticResponses['misai_blockchain'];
    }
    
    // ABHA Health ID related keywords
    if (message.contains('abha') || 
        message.contains('health id') || 
        message.contains('digital health') ||
        message.contains('health identity')) {
      return _staticResponses['abha_health_id'];
    }
    
    // Health insurance related keywords
    if (message.contains('health insurance') || 
        message.contains('medical insurance') ||
        message.contains('insurance plan') ||
        message.contains('insurance coverage')) {
      return _staticResponses['health_insurance'];
    }
    
    // Registration related keywords
    if (message.contains('registration') || 
        message.contains('register') ||
        message.contains('sign up') ||
        message.contains('how to apply')) {
      return _staticResponses['registration_process'];
    }
    
    // Policy and claims related keywords
    if (message.contains('policy') || 
        message.contains('claim') ||
        message.contains('cashless') ||
        message.contains('reimbursement')) {
      return _staticResponses['policy_claims'];
    }
    
    return null;
  }
  
  
  void _stopListening() async {
    setState(() => _isListening = false);
    await _speech.stop();
  }
  
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    setState(() {
      _showQuickPrompts = false;
    });
    
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    // Send to API
    _sendToAPI(message);
  }
  
  Future<void> _sendToAPI(String message) async {
    // First check for static response
    final staticResponse = _getStaticResponse(message);
    
    if (staticResponse != null) {
      // Use static response for faster reply
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: staticResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
        _isTyping = false;
      });
      
      _scrollToBottom();
      if (_ttsEnabled) {
        await _speak(botMessage.text, botMessage.id);
      }
      return;
    }
    
    // If no static response found, use API
    try {
      final response = await http.post(
        Uri.parse('https://care.techmisai.com/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        String result;
        try {
          final decoded = jsonDecode(response.body);
          result = decoded['result'] ?? decoded['message'] ?? decoded.toString();
          
          // Clean up response
          result = result
              .replaceAll(RegExp(r'\{answer:\s?'), '')
              .replaceAll(RegExp(r'\}'), '')
              .trim();
        } catch (e) {
          result = response.body;
        }
        
        final botMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: result,
          isUser: false,
          timestamp: DateTime.now(),
        );
        
        setState(() {
          _messages.add(botMessage);
          _isLoading = false;
          _isTyping = false;
        });
        
        _scrollToBottom();
        if (_ttsEnabled) {
          await _speak(botMessage.text, botMessage.id);
        }
      } else {
        throw Exception('Failed to get response');
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "I apologize, but I'm having trouble connecting right now. "
            "Please try again later or check your internet connection.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
        _isTyping = false;
      });
      
      _scrollToBottom();
      if (_ttsEnabled) {
        await _speak(errorMessage.text, errorMessage.id);
      }
    }
  }
  
 
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Widget _buildPopupHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
          decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
       child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'lib/assets/images/MisaiCare1.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
     ),
     ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Misai Assistant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isListening ? 'Listening...' : 'Online',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _ttsEnabled = !_ttsEnabled;
                  if (!_ttsEnabled && _isSpeaking) {
                    _stopSpeaking();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickPrompts() {
    if (!_showQuickPrompts) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Options:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_quickPrompts.length, (index) {
            final prompt = _quickPrompts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleQuickPrompt(prompt['prompt']!),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              prompt['icon']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prompt['title']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prompt['description']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? primaryBlue : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser 
                        ? null 
                        : Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(message.timestamp),
                            style: TextStyle(
                              color: isUser ? Colors.white70 : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (!isUser) ...[
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _currentSpeakingMessageId == message.id && _isSpeaking
                                  ? _stopSpeaking()
                                  : _speak(message.text, message.id),
                              child: Icon(
                                _currentSpeakingMessageId == message.id && _isSpeaking
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 16,
                                color: _currentSpeakingMessageId == message.id && _isSpeaking
                                    ? primaryGreen
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (message.hasPrompts && _showQuickPrompts) _buildQuickPrompts(),
      ],
    );
  }
  
  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final animationValue = _typingAnimationController.value;
        final opacity = (animationValue + index * 0.3) % 1.0;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(opacity > 0.5 ? 1.0 : 0.3),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: _isListening ? 'Listening...' : 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isListening ? primaryGreen : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF5BCC6A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVoiceListeningOverlay() {
    if (!_isListening) return const SizedBox();
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvatarGlow(
                glowColor: primaryGreen,
                endRadius: 100.0,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                showTwoGlows: true,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _lastWords.isNotEmpty ? _lastWords : 'Listening...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: _stopListening,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Stop Listening',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: SafeArea(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          )),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildPopupHeader(),
                      Expanded(
                        child: Container(
                         color: const Color.fromARGB(0, 255, 255, 255), 
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _messages.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _messages.length && _isLoading) {
                                return _buildTypingIndicator();
                              }
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                        ),
                      ),
                      _buildMessageInput(),
                    ],
                  ),
                  _buildVoiceListeningOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    _slideAnimationController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasPrompts;
  
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.hasPrompts = false,
  });
}