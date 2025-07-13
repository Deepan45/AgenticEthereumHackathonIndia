import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:misai_care/welcome_screen.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late ScrollController _featureScrollController;
  

 @override
void initState() {
  super.initState();

  _featureScrollController = ScrollController();

  Future.delayed(Duration(seconds: 2), () {
    _featureScrollController.animateTo(
      130.0, 
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  });

  _fadeController = AnimationController(
    duration: Duration(milliseconds: 1800),
    vsync: this,
  );
  _slideController = AnimationController(
    duration: Duration(milliseconds: 1500),
    vsync: this,
  );
  _scaleController = AnimationController(
    duration: Duration(milliseconds: 2000),
    vsync: this,
  );

  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeInOut,
  ));

  _slideAnimation = Tween<Offset>(
    begin: Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  ));

  _scaleAnimation = Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _scaleController,
    curve: Curves.elasticOut,
  ));

  _fadeController.forward();
  _slideController.forward();
  _scaleController.forward();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildHeroSection(),
              _buildFeatureSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Color(0xFF5BCC6A), Color(0xFF1A4D9E)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'lib/assets/images/MisaiCare1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Misai',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A4D9E),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Care',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5BCC6A),
                letterSpacing: -0.5,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF1A4D9E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Beta',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A4D9E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              _buildHeroImage(),
              SizedBox(height: 10),
             _buildHeroButtons(context)           
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: 450,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5BCC6A).withOpacity(0.1),
              Color(0xFF1A4D9E).withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            ...List.generate(8, (index) => _buildFloatingParticle(index)),
              Positioned(
              top: 60,
              left: 10,
              child: _buildEnhancedFloatingCard(
                'DID + ABHA\nIntegration',
                Icons.verified_user,
                Color(0xFF5BCC6A),
                'Secure identity verification',
              ),
            ),
            Positioned(
              top: 70,
              right: 5,
              child: _buildEnhancedFloatingCard(
                'Verifiable\nCredentials',
                Icons.security,
                Color(0xFF1A4D9E),
                'Blockchain-based proof',
              ),
            ),
            Positioned(
              bottom: 70,
              left: 5,
              child: _buildEnhancedFloatingCard(
                'Privacy-preserving\nClaims via ZKP',
                Icons.privacy_tip,
                Color(0xFF5BCC6A),
                'Zero-knowledge proofs',
              ),
            ),
            Positioned(
              bottom: 60,
              right: 5,
              child: _buildEnhancedFloatingCard(
                'DAO-based\nGovernance',
                Icons.account_balance,
                Color(0xFF1A4D9E),
                'Community-driven decisions',
              ),
            ),
            
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF5BCC6A).withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(52),
                    gradient: LinearGradient(
                      colors: [Color(0xFF5BCC6A), Color(0xFF1A4D9E)],
                    ),
                  ),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(52),
                  child: Container(
                    width: 80, 
                    height: 80,
                    color: Colors.white, 
                    padding: EdgeInsets.all(8), 
                    child: Image.asset(
                      'lib/assets/images/MisaiCare1.png',
                      fit: BoxFit.contain, 
                    ),
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = [0.2, 0.7, 0.9, 0.3, 0.6, 0.8, 0.1, 0.4][index];
    return Positioned(
      top: 50 + (index * 40.0),
      left: 30 + (random * 280),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Color(0xFF5BCC6A).withOpacity(0.3),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildEnhancedFloatingCard(String title, IconData icon, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          _buildFeatureGrid(),
        ],
      ),
    );
  }

Widget _buildFeatureGrid() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SingleChildScrollView(
      controller: _featureScrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSimpleFeatureCard('Instant Claims', Icons.flash_on),
          SizedBox(width: 16),
          _buildSimpleFeatureCard('24/7 Support', Icons.support_agent),
          SizedBox(width: 16),
          _buildSimpleFeatureCard('Transparent', Icons.visibility),
          SizedBox(width: 16),
          _buildSimpleFeatureCard('Secure', Icons.shield),
        ],
      ),
    ),
  );
}

Widget _buildSimpleFeatureCard(String title, IconData icon) {
  return Container(
    width: 120,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(0),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xFF5BCC6A).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: Color(0xFF5BCC6A)),
        ),
        SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

Widget _buildHeroButtons(BuildContext context) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40), 
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5BCC6A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
              shadowColor: const Color(0xFF5BCC6A).withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
}