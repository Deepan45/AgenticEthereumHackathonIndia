import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:misai_care/chatbot_page.dart';
import 'package:misai_care/insurance_detail_page.dart';
import 'package:misai_care/utils/wallet_connector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';
import 'package:misai_care/models/insurance_plan.dart';
import 'package:misai_care/models/recommendation.dart';

class DashboardScreen extends StatefulWidget {
  final String walletAddress;
  final String did;
  final Map<String, dynamic> abhaData;

  const DashboardScreen({
    super.key,
    required this.walletAddress,
    required this.did,
    required this.abhaData,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late WalletConnector _walletConnector;
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<HealthPlan> _healthPlans = [];
  List<SurveyData> _surveyHistory = [];
  List<InsurancePlan> _insurancePlans = [];
  List<Recommendation> _recommendations = [];
  bool _loading = true;
  bool _loadingPlans = false;
  bool _loadingRecommendations = false;
  // SurveyInput? _lastSurveyInput;
  bool _showSurvey = false;
  final Map<String, dynamic> _currentSurveyAnswers = {};
  int _currentQuestionIndex = 0;
  final PageController _recommendationPageController = PageController();
  Timer? _recommendationAutoScrollTimer;
  int _currentRecommendationPage = 0;
  bool _isRecommendationAutoScrolling = true;

  static const Color primaryBlue = Color(0xFF1A4D9E);
  static const Color primaryGreen = Color(0xFF5BCC6A);
  static const Color lightBlue = Color(0xFF2D5FBF);
  static const Color darkBlue = Color(0xFF0F2F5F);
  static const Color lightGreen = Color(0xFF7DD87F);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  final List<SurveyQuestion> _surveyQuestions = [
    SurveyQuestion(
    id: 'age',
    question: 'What is your age group?',
    type: QuestionType.singleChoice,
    options: ['Under 18', '18-25', '26-35', '36-45', '46-55', '56-65', '66+'],
    icon: Icons.cake,
  ),
    SurveyQuestion(
      id: 'income',
      question: 'What is your approximate monthly income?',
      type: QuestionType.singleChoice,
      options: ['Below ₹10k', '₹10k-₹25k', '₹25k-₹50k', '₹50k-₹1L', 'Above ₹1L'],
      icon: Icons.money,
    ),
    SurveyQuestion(
      id: 'familySize',
      question: 'How many family members need coverage?',
      type: QuestionType.singleChoice,
      options: ['1', '2-3', '4-5', '6-8', '9+'],
      icon: Icons.family_restroom,
    ),
    SurveyQuestion(
      id: 'risk',
      question: 'How would you describe your health risk?',
      type: QuestionType.singleChoice,
      options: ['Low', 'Medium', 'High'],
      icon: Icons.health_and_safety,
    ),
    SurveyQuestion(
      id: 'conditions',
      question: 'Any existing medical conditions? (Select all that apply)',
      type: QuestionType.multipleChoice,
      options: ['Diabetes', 'Hypertension', 'Asthma', 'Heart Disease', 'None'],
      icon: Icons.medical_services,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _walletConnector = WalletConnector();
     _startRecommendationAutoScroll();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
      _saveUserData();
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _recommendationAutoScrollTimer?.cancel();
   _recommendationPageController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadSurveyHistory();
    await _loadHealthPlans();
    await _fetchInsurancePlans();
    setState(() => _loading = false);
    _animationController.forward();
  }


Future<void> _getRecommendations(SurveyInput input) async {
  setState(() {
    _loadingRecommendations = true;
    _recommendations = []; 
  });

  try {
    final response = await http.post(
      Uri.parse('http://192.168.8.135:5000/api/recommend-policy'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    ).timeout(const Duration(seconds: 3000));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['recommendations'] is List) {
        setState(() {
          _recommendations = (data['recommendations'] as List)
              .map((rec) => Recommendation.fromJson(rec))
              .toList();
          _loadingRecommendations = false;
        });
      } else {
        setState(() => _loadingRecommendations = false);
        _showWarningSnackBar('Invalid response format from server');
      }
    } else {
      setState(() => _loadingRecommendations = false);
      _showWarningSnackBar('Server error: ${response.statusCode}');
    }
  } catch (e) {
    setState(() => _loadingRecommendations = false);
    _showWarningSnackBar('Failed to load recommendations: ${e.toString()}');
  }
}

  void _startRecommendationAutoScroll() {
  _recommendationAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
    if (!_isRecommendationAutoScrolling || 
        !_recommendationPageController.hasClients || 
        _recommendations.isEmpty) return;
    
    final nextPage = _currentRecommendationPage < _recommendations.length - 1 
        ? _currentRecommendationPage + 1 
        : 0;
    _recommendationPageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  });
}

void _toggleRecommendationAutoScroll() {
  setState(() {
    _isRecommendationAutoScrolling = !_isRecommendationAutoScrolling;
  });
  if (_isRecommendationAutoScrolling) {
    _startRecommendationAutoScroll();
  } else {
    _recommendationAutoScrollTimer?.cancel();
  }
}
 Widget _buildRecommendationCarousel() {
    // 1. Loading State
    if (_loadingRecommendations) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        color: Colors.white,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
        ),
      );
    }

    // 2. Empty State (simplified)
    if (_recommendations.isEmpty) {
      return Container(
        height: 220,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 40, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No recommendations found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  // 3. Carousel Content
  return Column(
    children: [
      SizedBox(
        height: 790, // Increased height
        child: Stack(
          children: [
            PageView.builder(
              controller: _recommendationPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentRecommendationPage = index;
                });
              },
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildRecommendationCard(_recommendations[index]),
                );
              },
            ),

            // Navigation arrows
            if (_recommendations.length > 1) ...[
              // Left arrow
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chevron_left, color: primaryBlue),
                    ),
                    onPressed: () {
                      _recommendationPageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),

              // Right arrow
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chevron_right, color: primaryBlue),
                    ),
                    onPressed: () {
                      _recommendationPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      const SizedBox(height: 12),

      // Pagination & Auto-scroll
      if (_recommendations.length > 1) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pagination dots
            Row(
              children: List.generate(
                _recommendations.length,
                (index) => GestureDetector(
                  onTap: () {
                    _recommendationPageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentRecommendationPage == index
                          ? primaryBlue
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Auto-scroll toggle
            GestureDetector(
              onTap: _toggleRecommendationAutoScroll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isRecommendationAutoScrolling
                      ? primaryBlue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRecommendationAutoScrolling ? Icons.pause : Icons.play_arrow,
                      size: 16,
                      color: _isRecommendationAutoScrolling ? primaryBlue : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isRecommendationAutoScrolling ? 'Auto' : 'Manual',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isRecommendationAutoScrolling ? primaryBlue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ],
  );
}


Future<void> _saveUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('abha_id', widget.abhaData['ABHANumber'] ?? '');
  await prefs.setString('wallet_address', widget.walletAddress);
  await prefs.setString('user_name', widget.abhaData['name'] ?? '');
  await prefs.setString('did', widget.did);
  
  if (widget.abhaData['profilePhoto'] != null) {
    await prefs.setString('profile_photo', widget.abhaData['profilePhoto']);
  }
}

Future<Map<String, dynamic>> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'ABHANumber': prefs.getString('abha_id') ?? '',
    'walletAddress': prefs.getString('wallet_address') ?? '',
    'name': prefs.getString('user_name') ?? '',
    'did': prefs.getString('did') ?? '',
    'profilePhoto': prefs.getString('profile_photo'),
  };
}

  Future<void> _fetchInsurancePlans() async {
    setState(() => _loadingPlans = true);
    try {
      final response = await http.get(Uri.parse('http://192.168.8.135:5000/api/plans'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _insurancePlans = data.map((plan) => InsurancePlan.fromJson(plan)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching insurance plans: $e');
    } finally {
      setState(() => _loadingPlans = false);
    }
  }
  Future<void> _loadSurveyHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final surveysJson = prefs.getStringList('survey_history') ?? [];
    setState(() {
      _surveyHistory = surveysJson
          .map((json) => SurveyData.fromJson(jsonDecode(json)))
          .toList();
    });
  }

 void _navigateToInsuranceDetail(Recommendation recommendation) {
  final matchingPlan = _insurancePlans.firstWhere(
    (plan) => plan.policyName == recommendation.policyName,
    orElse: () => InsurancePlan(
      policyName: recommendation.policyName,
      insurer: "Unknown Insurer",
      sumInsuredRange: "Custom Range",
    ),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InsuranceDetailPage(
        plan: matchingPlan,
        recommendation: recommendation,
      ),
    ),
  );
}

void _navigateToPlanDetail(InsurancePlan plan) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InsuranceDetailPage(plan: plan),
    ),
  );
}

  Future<void> _loadHealthPlans() async {
    try {
      final plans = await _walletConnector.getHealthPlans();
      if (plans.isNotEmpty) {
        setState(() => _healthPlans = plans);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList('health_plans') ?? [];
      setState(() {
        _healthPlans = plansJson
            .map((json) => HealthPlan.fromJson(jsonDecode(json)))
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading health plans: $e');
    }
  }

 Future<void> _saveSurveyData() async {
  final surveyData = SurveyData(
    answers: Map.from(_currentSurveyAnswers),
    timestamp: DateTime.now(),
  );

  final surveyInput = SurveyInput(
    income: _currentSurveyAnswers['income'] ?? '₹10k',
    age: _currentSurveyAnswers['age'] ?? '18-25', 
    familySize: int.tryParse(_currentSurveyAnswers['familySize']?.toString().split('-').first ?? '1') ?? 1,
    risk: _currentSurveyAnswers['risk'] ?? 'Medium',
    conditions: _currentSurveyAnswers['conditions'] is List 
        ? List<String>.from(_currentSurveyAnswers['conditions'])
        : [_currentSurveyAnswers['conditions']?.toString() ?? 'None'],
  );


  setState(() {
    _surveyHistory.insert(0, surveyData);
    _showSurvey = false;
    _currentSurveyAnswers.clear();
    _currentQuestionIndex = 0;
  });

  final prefs = await SharedPreferences.getInstance();
  final surveysJson = _surveyHistory.map((s) => jsonEncode(s.toJson())).toList();
  await prefs.setStringList('survey_history', surveysJson);

  await _getRecommendations(surveyInput);
  await _generateHealthPlan(surveyData);
}

  Future<void> _generateHealthPlan(SurveyData surveyData) async {
    final planId = 'plan_${DateTime.now().millisecondsSinceEpoch}';
    final recommendations = _analyzeSurvey(surveyData);

    final newPlan = HealthPlan(
      id: planId,
      title: 'Health Plan ${DateFormat('MMM dd').format(DateTime.now())}',
      description: 'Personalized recommendations based on your survey',
      recommendations: recommendations,
      created: DateTime.now(),
    );

    setState(() => _healthPlans.insert(0, newPlan));

    final prefs = await SharedPreferences.getInstance();
    final plansJson = _healthPlans.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('health_plans', plansJson);

    try {
      await _walletConnector.saveHealthPlan(newPlan);
      _showSuccessSnackBar('Health plan saved successfully!');
    } catch (e) {
      debugPrint('Failed to save to blockchain: $e');
      _showWarningSnackBar('Saved locally (blockchain error)');
    }
  }

  List<String> _analyzeSurvey(SurveyData survey) {
    final recommendations = <String>[];
    final answers = survey.answers;

    if (answers.containsKey('risk') && answers['risk'] == 'High') {
      recommendations.add('Consider comprehensive health coverage');
    }

    if (answers.containsKey('familySize')) {
      final size = int.tryParse(answers['familySize'].toString().split('-').first) ?? 1;
      if (size > 3) {
        recommendations.add('Family floater plan might be cost-effective');
      }
    }

    if (answers.containsKey('conditions')) {
      final conditions = answers['conditions'] is List ? answers['conditions'] : [answers['conditions']];
      if (conditions.contains('Diabetes') || conditions.contains('Hypertension')) {
        recommendations.add('Look for plans with good chronic condition coverage');
      }
    }

     if (answers.containsKey('age')) {
    final age = answers['age'].toString();
    if (age == 'Under 18') {
      recommendations.add('Consider child-specific health plans');
    } else if (age == '66+') {
      recommendations.add('Look for senior citizen specific plans');
    } else if (age == '46-55' || age == '56-65') {
      recommendations.add('Consider comprehensive coverage for preventive care');
    }
  }

    if (recommendations.isEmpty) {
      recommendations.add('Standard health insurance should meet your needs');
    }

    return recommendations;
  }

  void _handleSurveyAnswer(String questionId, dynamic answer) {
    setState(() {
      _currentSurveyAnswers[questionId] = answer;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                backgroundImage: widget.abhaData['profilePhoto'] != null
                    ? MemoryImage(base64Decode(widget.abhaData['profilePhoto']))
                    : null,
                child: widget.abhaData['profilePhoto'] == null
                    ? const Icon(Icons.person, size: 35, color: primaryBlue)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.abhaData['name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ABHA: ${_formatAbhaNumber(widget.abhaData['ABHANumber'] ?? '')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, 
                         size: 14, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      _shortenAddress(widget.walletAddress),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.qr_code, color: Colors.white),
              onPressed: () => _showQrCode(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAbhaNumber(String abha) {
    if (abha.length < 14) return abha;
    return '${abha.substring(0, 2)}-${abha.substring(2, 6)}-${abha.substring(6, 10)}-${abha.substring(10, 14)}';
  }

  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPlanCard(HealthPlan plan, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryGreen.withOpacity(0.1), primaryGreen.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, y').format(plan.created),
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.description,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Recommendations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...plan.recommendations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final recommendation = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: primaryGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    recommendation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


// Helper widget for detail rows
Widget _buildDetailRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey.shade600),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
 
Widget _buildRecommendationCard(Recommendation recommendation) {
  if (recommendation.policyName.isEmpty ||
      recommendation.why.isEmpty ||
      recommendation.matchReasons.isEmpty ||
      recommendation.summary.isEmpty) {
    return const SizedBox.shrink();
  }
  final scoreColor = _getScoreColor(recommendation.score);
  final borderColor = scoreColor.withOpacity(0.5);
  final bgColor = scoreColor.withOpacity(0.08);

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 2.0,  
          ),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Match Score
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      recommendation.policyName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${recommendation.score}% Match',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Why this plan?
              if (recommendation.why.isNotEmpty) ...[
                const Text(
                  'Why this plan?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation.why,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Key Features
              if (recommendation.matchReasons.isNotEmpty) ...[
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ...recommendation.matchReasons.map((reason) => reason.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 18, color: primaryGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 14.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()).toList(),
                const SizedBox(height: 20),
              ],

              // Summary
              if (recommendation.summary.isNotEmpty) ...[
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation.summary,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToInsuranceDetail(recommendation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "View Plan Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
// Helper to get color based on score
Color _getScoreColor(int score) {
  return score > 80
      ? primaryGreen
      : score > 60
          ? Colors.orange
          : Colors.red;
}

  Widget _buildSurveyQuestion(SurveyQuestion question) {
    switch (question.type) {
      case QuestionType.scale:
      case QuestionType.singleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(question.icon, color: primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.options!.map((option) {
                final isSelected = _currentSurveyAnswers[question.id] == option;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleSurveyAnswer(question.id, option),
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryBlue : cardBackground,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? primaryBlue : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case QuestionType.multipleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(question.icon, color: primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...question.options!.map((option) {
              final isSelected = _currentSurveyAnswers[question.id] != null &&
                  (_currentSurveyAnswers[question.id] as List).contains(option);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen.withOpacity(0.1) : cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryGreen : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  value: isSelected,
                  onChanged: (selected) {
                    final current = List<String>.from(
                      (_currentSurveyAnswers[question.id] as List?) ?? [],
                    );
                    if (selected == true) {
                      current.add(option);
                    } else {
                      current.remove(option);
                    }
                    _handleSurveyAnswer(question.id, current);
                  },
                  activeColor: primaryGreen,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              );
            }),
          ],
        );

      case QuestionType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(question.icon, color: primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => _handleSurveyAnswer(question.id, value),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your response...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryBlue, width: 2),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildInsurancePlanCarousel() {
  return SizedBox(
    height: 380, // Fixed height for carousel
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _insurancePlans.length,
      itemBuilder: (context, index) {
        return _buildInsuranceCardForCarousel(_insurancePlans[index]);
      },
    ),
  );
}

Widget _buildInsuranceCardForCarousel(InsurancePlan plan) {
  return Container(
    width: 280, // Fixed card width
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A4D9E), 
          Color(0xFF2D5FBF),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade800.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 2,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Decorative elements
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        
        // Card content
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Policy info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Policy name and tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          plan.policyName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Popular",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Insurer
                  Row(
                    children: [
                      Icon(Icons.business, size: 18, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 8),
                      Text(
                        plan.insurer,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Details row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      icon: Icons.account_balance_wallet,
                      label: "Sum Insured",
                      value: plan.sumInsuredRange,
                    ),
                    _buildDetailItem(
                      icon: Icons.percent,
                      label: "Claim Ratio",
                      value: "98.2%",
                    ),
                    _buildDetailItem(
                      icon: Icons.star,
                      label: "Rating",
                      value: "4.8",
                    ),
                  ],
                ),
              ),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => _navigateToPlanDetail(plan),
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BCC6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View Plan Details",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildDetailItem({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Column(
    children: [
      Icon(icon, size: 20, color: Colors.white),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    ],
  );
}

  Widget _buildSurveyForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment, color: primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Health Assessment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _surveyQuestions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_surveyQuestions.length}',
            style: const TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _buildSurveyQuestion(_surveyQuestions[_currentQuestionIndex]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _currentQuestionIndex--);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: primaryBlue),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < _surveyQuestions.length - 1) {
                      setState(() => _currentQuestionIndex++);
                    } else {
                      _saveSurveyData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex < _surveyQuestions.length - 1 ? 'Next' : 'Submit',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _showSurvey = false;
                _currentSurveyAnswers.clear();
                _currentQuestionIndex = 0;
              });
            },
            child: const Text(
              'Cancel Assessment',
              style: TextStyle(color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyHistoryItem(SurveyData survey, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history, color: primaryGreen, size: 20),
                  ),
                  title: Text(
                    DateFormat('MMM d, y').format(survey.timestamp),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('h:mm a').format(survey.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: survey.answers.entries.map((entry) {
                          final question = _surveyQuestions.firstWhere((q) => q.id == entry.key);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(question.icon, color: primaryBlue, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        question.question,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.value is List 
                                      ? (entry.value as List).join(', ')
                                      : entry.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'lib/assets/images/MisaiCare1.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
           const SizedBox(height: 16),
              const Text(
                'Misai Health ID',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code, size: 80, color: primaryBlue),
                      const SizedBox(height: 8),
                      Text(
                        widget.abhaData['ABHANumber'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.abhaData['name'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: () => _openChatbot(context),
          backgroundColor: const Color(0xFF5BCC6A),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 36),
        ),
      ),
      backgroundColor: backgroundColor,
     appBar: PreferredSize(
  preferredSize: const Size.fromHeight(90),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF8FAFC),
          const Color(0xFFEEF2FF),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6366F1).withOpacity(0.08),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'lib/assets/images/MisaiCare1.png',
                          width: 46,
                          height: 46,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.local_hospital_rounded,
                              color: Color(0xFF6366F1),
                              size: 28,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Brand Text with Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'MisaiCare',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'System Online',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Premium Action Panel
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  
                  _buildPremiumButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                    hasNotification: true,
                    isCompact: true,
                  ),
                  const SizedBox(width: 4),
                  
                  // Refresh Button
                  _buildPremiumButton(
                    icon: Icons.refresh_rounded,
                    onTap: _initializeData,
                    isActive: true,
                    isCompact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
    body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
              ),
            )
          : _showSurvey
              ? SingleChildScrollView(child: _buildSurveyForm())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 20),
                          
                          // Stats Cards
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatsCard(
                                    'Health Plans',
                                    '${_healthPlans.length}',
                                    Icons.medical_services,
                                    primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatsCard(
                                    'Assessments',
                                    '${_surveyHistory.length}',
                                    Icons.assignment,
                                    primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                                  if (_recommendations.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: primaryBlue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.recommend, color: primaryBlue, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Recommended Plans',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildRecommendationCarousel(),
                                    const SizedBox(height: 24),
                                  ] else ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.search_off,
                                              size: 64,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No recommended plans found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'We couldn’t find any plans that match your profile.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],

                          // Insurance Plans Section
                          if (_insurancePlans.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.business, color: primaryGreen, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Available Insurance Plans',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                              const SizedBox(height: 16),
                              _buildInsurancePlanCarousel(),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to full plans list
                                },
                                child: const Text(
                                  'View All Plans',
                                  style: TextStyle(color: primaryBlue),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Health Plans Section
                          if (_healthPlans.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.favorite, color: primaryGreen, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Your Health Plans',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: _healthPlans.asMap().entries.map((entry) {
                                  return _buildHealthPlanCard(entry.value, entry.key);
                                }).toList(),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Action Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildActionButton(
                              'Take Health Assessment',
                              Icons.medical_services,
                              () => setState(() => _showSurvey = true),
                              primaryBlue,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Survey History
                          if (_surveyHistory.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.history, color: primaryBlue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Assessment History',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: _surveyHistory.asMap().entries.map((entry) {
                                  return _buildSurveyHistoryItem(entry.value, entry.key);
                                }).toList(),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
            );
          }
        }

void _openChatbot(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: const Color.fromARGB(0, 255, 255, 255), 
      pageBuilder: (_, __, ___) => const ChatbotPage(),
    ),
  );
}


enum QuestionType { scale, singleChoice, multipleChoice, text }

class SurveyQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String>? options;
  final IconData icon;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    required this.icon,
  });
}

class SurveyData {
  final Map<String, dynamic> answers;
  final DateTime timestamp;

  SurveyData({required this.answers, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'answers': answers,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SurveyData.fromJson(Map<String, dynamic> json) => SurveyData(
        answers: json['answers'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class HealthPlan {
  final String id;
  final String title;
  final String description;
  final List<String> recommendations;
  final DateTime created;

  HealthPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.created,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'recommendations': recommendations,
        'created': created.toIso8601String(),
      };

  factory HealthPlan.fromJson(Map<String, dynamic> json) => HealthPlan(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        recommendations: List<String>.from(json['recommendations']),
        created: DateTime.parse(json['created']),
      );
}

class SurveyInput {
  final String income;
  final String age; 
  final int familySize;
  final String risk;
  final List<String> conditions;

  SurveyInput({
    required this.income,
    required this.familySize,
    required this.risk,
    required this.age, 
    required this.conditions,
  });

  Map<String, dynamic> toJson() => {
        'income': income,
        'familySize': familySize,
        'age': age,
        'risk': risk,
        'conditions': conditions,
      };
}

Widget _buildPremiumButton({
  required IconData icon,
  required VoidCallback onTap,
  String? label,
  bool isActive = false,
  bool hasNotification = false,
  bool isCompact = false,
}) {
  return Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: const Color(0xFF6366F1).withOpacity(0.1),
      highlightColor: const Color(0xFF6366F1).withOpacity(0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isActive ? LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              const Color(0xFF8B5CF6).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            width: 1,
          ) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isActive 
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF64748B),
                  size: 20,
                ),
                if (hasNotification)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (label != null && !isCompact) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive 
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
