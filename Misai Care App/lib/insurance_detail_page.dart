import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:misai_care/models/insurance_plan.dart';
import 'package:misai_care/models/recommendation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class InsuranceDetailPage extends StatefulWidget {
  final InsurancePlan plan;
  final Recommendation? recommendation;

  const InsuranceDetailPage({
    super.key,
    required this.plan,
    this.recommendation,
  });

  @override
  State<InsuranceDetailPage> createState() => _InsuranceDetailPageState();
}

class _InsuranceDetailPageState extends State<InsuranceDetailPage> {
  bool _isExpanded = false;
  bool _loadingEnrollment = false;
  bool _isEnrolled = false;
  String? _vcData;
  final double _headerHeight = 280;

  @override
  void initState() {
    super.initState();
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEnrollment = prefs.getString('last_enrollment');
    
    if (lastEnrollment != null) {
      try {
        final data = jsonDecode(lastEnrollment);
        if (data['policyName'] == widget.plan.policyName && 
            data['insurer'] == widget.plan.insurer) {
          setState(() {
            _isEnrolled = true;
            _vcData = lastEnrollment;
          });
        }
      } catch (e) {
        debugPrint('Error parsing enrollment data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecommended = widget.recommendation != null;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: _headerHeight,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: _buildFlexibleSpaceBar(theme, isRecommended, size),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: _sharePlan,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildStatsRow(theme),
                  const SizedBox(height: 24),
                  if (isRecommended) ...[
                    _buildWhyRecommendedSection(theme),
                    const SizedBox(height: 24),
                  ],
                  _buildCoverageSection(theme),
                  const SizedBox(height: 24),
                  _buildKeyBenefitsSection(theme),
                  const SizedBox(height: 24),
                  _buildPolicyDetailsSection(theme),
                  const SizedBox(height: 32),
                  _buildActionButtons(theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildFlexibleSpaceBar(ThemeData theme, bool isRecommended, Size size) {
  return FlexibleSpaceBar(
    collapseMode: CollapseMode.pin,
    background: Stack(
      fit: StackFit.expand,
      children: [
        // Enhanced Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A4D9E),
                const Color(0xFF1A4D9E),
                const Color(0xFF1A4D9E),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated floating elements with better positioning
        Positioned(
          right: -80,
          top: 30,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
          ),
        ),
        
        Positioned(
          left: -60,
          bottom: 60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
          ),
        ),
        
        // Additional decorative element
        Positioned(
          right: 40,
          bottom: 120,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        
        // Content with improved spacing
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main heading - Policy Name
              Text(
                widget.plan.policyName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: 0.8,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Insurer name (smaller subtitle)
              Text(
                widget.plan.insurer,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16), // Increased spacing
              
              // Recommendation badge with enhanced design
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.recommendation!.score}% Match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 12), // Additional bottom spacing
              
              // Optional: Add a subtle description or tagline
              Text(
                'Professional Coverage',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        
        // Subtle overlay for better text contrast
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  
  Widget _buildStatsRow(ThemeData theme) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Sum Insured',
            value: widget.plan.sumInsuredRange,
            color: const Color(0xFF6A11CB),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.king_bed_rounded,
            title: 'Room Rent',
            value: 'No Limit',
            color: const Color(0xFF2575FC),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.local_hospital_rounded,
            title: 'Hospitals',
            value: '10,000+',
            color: const Color(0xFF11998E),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyRecommendedSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF11998E).withOpacity(0.1),
            const Color(0xFF38EF7D).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF11998E).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11998E).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.thumb_up_rounded,
                    size: 20,
                    color: Color(0xFF11998E),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Why Recommended For You',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.recommendation!.why,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
            if (widget.recommendation!.matchReasons.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...widget.recommendation!.matchReasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: const Color(0xFF11998E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reason,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coverage Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildCoverageItem(
              icon: Icons.medical_services_rounded,
              title: 'Hospitalization',
              value: 'Full Coverage',
              color: const Color(0xFF6A11CB),
            ),
            _buildCoverageItem(
              icon: Icons.airline_seat_flat_rounded,
              title: 'Pre/Post Hospital',
              value: '60/90 Days',
              color: const Color(0xFF2575FC),
            ),
            _buildCoverageItem(
              icon: Icons.local_pharmacy_rounded,
              title: 'Daycare Procedures',
              value: 'Covered',
              color: const Color(0xFF11998E),
            ),
            _buildCoverageItem(
              icon: Icons.airport_shuttle_rounded,
              title: 'Ambulance',
              value: '₹5,000 per claim',
              color: const Color(0xFFF46B45),
            ),
            _buildCoverageItem(
              icon: Icons.health_and_safety_rounded,
              title: 'Pre-existing',
              value: 'After 4 years',
              color: const Color(0xFFFC4A1A),
            ),
            _buildCoverageItem(
              icon: Icons.monetization_on_rounded,
              title: 'No Claim Bonus',
              value: 'Up to 100%',
              color: const Color(0xFFF7971E),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverageItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyBenefitsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Benefits',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ..._getKeyBenefits().map((benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF11998E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF11998E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getKeyBenefits() => [
        'Cashless treatment at 10,000+ network hospitals across India',
        'Comprehensive coverage for pre (60 days) and post (90 days) hospitalization expenses',
        'No sub-limits on room rent or ICU charges - complete freedom of choice',
        '100% automatic restoration of sum insured for unrelated illnesses',
        'Coverage for alternative treatments (AYUSH) including Ayurveda and Homeopathy',
        'Organ donor expenses covered up to sum insured',
        'Domiciliary hospitalization covered when hospital admission is not possible',
      ];

  Widget _buildPolicyDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Policy Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                Icon(
                  _isExpanded 
                      ? Icons.keyboard_arrow_up_rounded 
                      : Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 12),
              _buildDetailRow(
                title: 'Policy Term',
                value: '1 Year',
                icon: Icons.calendar_today_rounded,
              ),
              _buildDetailRow(
                title: 'Renewability',
                value: 'Lifetime',
                icon: Icons.autorenew_rounded,
              ),
              _buildDetailRow(
                title: 'Waiting Period',
                value: '30 Days',
                icon: Icons.timer_rounded,
              ),
              _buildDetailRow(
                title: 'Pre-existing Waiting',
                value: '4 Years',
                icon: Icons.health_and_safety_rounded,
              ),
              _buildDetailRow(
                title: 'Free Look Period',
                value: '15 Days',
                icon: Icons.remove_red_eye_rounded,
              ),
              _buildDetailRow(
                title: 'Tax Benefits',
                value: 'Under Section 80D',
                icon: Icons.receipt_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        if (_isEnrolled)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF11998E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF11998E).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF11998E),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enrolled on ${_getEnrollmentDate()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isEnrolled ? _showVC : _loadingEnrollment ? null : _enrollNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isEnrolled 
                  ? Colors.white
                  : const Color(0xFF3A7BD5),
              foregroundColor: _isEnrolled 
                  ? const Color(0xFF3A7BD5)
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: _isEnrolled
                    ? BorderSide(
                        color: const Color(0xFF3A7BD5).withOpacity(0.5),
                        width: 1.5,
                      )
                    : BorderSide.none,
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: _loadingEnrollment
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEnrolled 
                            ? Icons.visibility_rounded 
                            : Icons.lock_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                 Text(
                    _isEnrolled ? 'View Policy VC' : 'Enroll Securely',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _isEnrolled ? Colors.black : Colors.white,
                    ),
                  ),
                    ],
                  ),
          ),
        ),
        if (!_isEnrolled) ...[
          const SizedBox(height: 12),
          Text(
            'Secure enrollment with end-to-end encryption',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  String _getEnrollmentDate() {
    if (_vcData == null) return 'Recently';
    try {
      final data = jsonDecode(_vcData!);
      final dateStr = data['enrollmentDate'];
      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      debugPrint('Error parsing enrollment date: $e');
    }
    return 'Recently';
  }

  Future<void> _enrollNow() async {
    setState(() => _loadingEnrollment = true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      final prefs = await SharedPreferences.getInstance();
      final storedAbhaId = prefs.getString('abha_id');
      final storedWallet = prefs.getString('wallet_address');
      final storedName = prefs.getString('user_name');

      final payload = {
        "PatientName": storedName ?? '',
        "abhaId": storedAbhaId ?? widget.recommendation?.abhaId ?? "ABHA-XXXX",
        "policyName": widget.plan.policyName,
        "insurer": widget.plan.insurer,
        "sumInsured": widget.plan.sumInsuredRange,
        "wallet": storedWallet ?? widget.recommendation?.walletAddress ?? "0x123ABCDEF",
        "enrollmentDate": DateTime.now().toIso8601String(),
        "policyNumber": "MISAI-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
      };

      final encoded = jsonEncode(payload);
      
      setState(() {
        _vcData = encoded;
        _isEnrolled = true;
        _loadingEnrollment = false;
      });

      await prefs.setString('last_enrollment', encoded);
      _showVC();
      
    } catch (e) {
      setState(() => _loadingEnrollment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enrollment failed: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showVC() {
    if (_vcData == null) return;
    
    final policyData = jsonDecode(_vcData!);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Misai Insurance Card',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Policy #${policyData['policyNumber'] ?? 'N/A'}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _vcData!,
                    size: 200,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF3A7BD5),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.plan.insurer,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3A7BD5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan.policyName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Share.share(_vcData!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7BD5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Share',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePlan() async {
    final text = 'Check out "${widget.plan.policyName}" health insurance '
        'by ${widget.plan.insurer} with sum insured up to ${widget.plan.sumInsuredRange}';
    
    await Share.share(text);
  }
}