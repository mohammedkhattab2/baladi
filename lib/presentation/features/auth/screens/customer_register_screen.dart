import 'dart:math' as math;
import 'dart:ui';

import 'package:baladi/core/constants/app_constants.dart';
import 'package:baladi/core/constants/security_questions.dart';
import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/extensions.dart';
import 'package:baladi/core/utils/validators.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Luxury Customer Registration Screen with magical animations and glowing effects
class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _referralController = TextEditingController();

  // Focus Nodes
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();
  final _securityAnswerFocus = FocusNode();
  final _referralFocus = FocusNode();

  // State
  String? _selectedQuestion;
  Map<String, String>? _fieldErrors;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _headerSlide = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _securityAnswerController.dispose();
    _referralController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    _securityAnswerFocus.dispose();
    _referralFocus.dispose();
    _backgroundController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  String? _validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تأكيد رمز الدخول مطلوب';
    }
    if (value.trim() != _pinController.text.trim()) {
      return 'رمز الدخول غير متطابق';
    }
    return null;
  }

  String? _validateOptionalReferral(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.validateReferralCode(value);
  }

  void _handleRegister(BuildContext blocContext) {
    setState(() => _fieldErrors = null);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedQuestion == null || _selectedQuestion!.isEmpty) {
      setState(() => _fieldErrors = {'security_question': 'اختر سؤال الأمان'});
      return;
    }

    FocusScope.of(blocContext).unfocus();

    final referral = _referralController.text.trim();

    blocContext.read<AuthCubit>().registerCustomer(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          pin: _pinController.text.trim(),
          securityQuestion: _selectedQuestion!,
          securityAnswer: _securityAnswerController.text.trim(),
          referralCode: referral.isEmpty ? null : referral,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _onAuthStateChanged,
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Scaffold(
            body: Stack(
              children: [
                // Animated gradient background
                _AnimatedGradientBackground(controller: _backgroundController),
                // Floating particles
                _FloatingParticles(
                  controller: _floatingController,
                  pulseController: _pulseController,
                ),
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Luxury Header
                            Transform.translate(
                              offset: Offset(0, _headerSlide.value),
                              child: Opacity(
                                opacity: _headerFade.value,
                                child: _LuxuryHeader(
                                  pulseController: _pulseController,
                                  onBack: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Form Container
                            Transform.translate(
                              offset: Offset(0, _formSlide.value),
                              child: Opacity(
                                opacity: _formFade.value,
                                child: _GlassmorphicFormContainer(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Section 1: Personal Data
                                        _LuxurySectionLabel(
                                          icon: Icons.person_outlined,
                                          label: 'البيانات الشخصية',
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 16.h),
                                        _LuxuryTextField(
                                          controller: _nameController,
                                          focusNode: _nameFocus,
                                          label: 'الاسم الكامل',
                                          hint: 'أدخل اسمك الكامل',
                                          prefixIcon: Icons.person_outlined,
                                          keyboardType: TextInputType.name,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          validator: Validators.validateName,
                                          errorText: _fieldErrors?['full_name'],
                                          onFieldSubmitted: (_) =>
                                              _phoneFocus.requestFocus(),
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 16.h),
                                        _LuxuryTextField(
                                          controller: _phoneController,
                                          focusNode: _phoneFocus,
                                          label: 'رقم الهاتف',
                                          hint: '01xxxxxxxxx',
                                          prefixIcon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 11,
                                          validator: Validators.validatePhone,
                                          errorText: _fieldErrors?['phone'],
                                          onFieldSubmitted: (_) =>
                                              _pinFocus.requestFocus(),
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 28.h),

                                        // Section 2: Security
                                        _LuxurySectionLabel(
                                          icon: Icons.lock_outlined,
                                          label: 'الأمان',
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 16.h),
                                        _LuxuryTextField(
                                          controller: _pinController,
                                          focusNode: _pinFocus,
                                          label: 'رمز الدخول',
                                          hint: '••••',
                                          prefixIcon: Icons.lock_outlined,
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                          obscureText: _obscurePin,
                                          validator: Validators.validatePin,
                                          errorText: _fieldErrors?['pin'],
                                          onFieldSubmitted: (_) =>
                                              _confirmPinFocus.requestFocus(),
                                          pulseController: _pulseController,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePin
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.white70,
                                              size: 22.r,
                                            ),
                                            onPressed: () => setState(
                                                () => _obscurePin = !_obscurePin),
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        _LuxuryTextField(
                                          controller: _confirmPinController,
                                          focusNode: _confirmPinFocus,
                                          label: 'تأكيد رمز الدخول',
                                          hint: '••••',
                                          prefixIcon: Icons.lock_outlined,
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                          obscureText: _obscureConfirmPin,
                                          validator: _validateConfirmPin,
                                          onFieldSubmitted: (_) =>
                                              _securityAnswerFocus.requestFocus(),
                                          pulseController: _pulseController,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPin
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.white70,
                                              size: 22.r,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscureConfirmPin =
                                                    !_obscureConfirmPin),
                                          ),
                                        ),
                                        SizedBox(height: 28.h),

                                        // Section 3: Security Question
                                        _LuxurySectionLabel(
                                          icon: Icons.shield_outlined,
                                          label: 'سؤال الأمان',
                                          subtitle: 'لاستعادة رمز الدخول لاحقاً',
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 16.h),
                                        _LuxurySecurityQuestionField(
                                          selectedQuestion: _selectedQuestion,
                                          onQuestionChanged: (q) =>
                                              setState(() => _selectedQuestion = q),
                                          answerController:
                                              _securityAnswerController,
                                          answerFocusNode: _securityAnswerFocus,
                                          questionError:
                                              _fieldErrors?['security_question'],
                                          answerError:
                                              _fieldErrors?['security_answer'],
                                          onAnswerSubmitted: (_) =>
                                              _referralFocus.requestFocus(),
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 28.h),

                                        // Section 4: Referral (Optional)
                                        _LuxurySectionLabel(
                                          icon: Icons.card_giftcard_outlined,
                                          label: 'رمز إحالة',
                                          badge: 'اختياري',
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 16.h),
                                        _LuxuryTextField(
                                          controller: _referralController,
                                          focusNode: _referralFocus,
                                          label: 'رمز الإحالة',
                                          hint: 'مثال: A3K9X2BF',
                                          prefixIcon: Icons.card_giftcard_outlined,
                                          keyboardType: TextInputType.text,
                                          maxLength: AppConstants.referralCodeLength,
                                          textCapitalization:
                                              TextCapitalization.characters,
                                          validator: _validateOptionalReferral,
                                          errorText: _fieldErrors?['referral_code'],
                                          onFieldSubmitted: (_) =>
                                              _handleRegister(context),
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 32.h),

                                        // Register Button
                                        _GlowingButton(
                                          text: 'إنشاء حساب',
                                          icon: Icons.person_add_outlined,
                                          isLoading: isLoading,
                                          onPressed: isLoading
                                              ? null
                                              : () => _handleRegister(context),
                                          pulseController: _pulseController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Login link
                            Opacity(
                              opacity: _formFade.value,
                              child: _LoginLink(
                                onTap: () => context.pop(),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black45,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Center(
                        child: _GlowingLoader(pulseController: _pulseController),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.goNamed(RouteNames.customerHome);
    } else if (state is AuthError) {
      if (state.fieldErrors != null && state.fieldErrors!.isNotEmpty) {
        setState(() => _fieldErrors = state.fieldErrors);
      } else {
        context.showErrorSnackBar(state.message);
      }
    }
  }
}

/// Animated gradient background
class _AnimatedGradientBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedGradientBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _interpolateColor(controller.value, 0),
                _interpolateColor(controller.value, 0.33),
                _interpolateColor(controller.value, 0.66),
                _interpolateColor(controller.value, 1.0),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }

  Color _interpolateColor(double t, double offset) {
    final colors = [
      const Color(0xFF0D1B2A),
      const Color(0xFF1B263B),
      const Color(0xFF2D5A27),
      const Color(0xFF1A3A16),
      const Color(0xFF0D1B2A),
    ];

    final adjustedT = (t + offset) % 1.0;
    final index = (adjustedT * (colors.length - 1)).floor();
    final localT = (adjustedT * (colors.length - 1)) - index;

    return Color.lerp(
        colors[index], colors[(index + 1) % colors.length], localT)!;
  }
}

/// Floating particles with glow effects
class _FloatingParticles extends StatelessWidget {
  final AnimationController controller;
  final AnimationController pulseController;

  const _FloatingParticles({
    required this.controller,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, pulseController]),
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            animationValue: controller.value,
            pulseValue: pulseController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double animationValue;
  final double pulseValue;
  final List<_Particle> particles;

  _ParticlesPainter({
    required this.animationValue,
    required this.pulseValue,
  }) : particles = _generateParticles();

  static List<_Particle> _generateParticles() {
    final random = math.Random(42);
    return List.generate(18, (index) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1.5,
        speed: random.nextDouble() * 0.3 + 0.1,
        opacity: random.nextDouble() * 0.4 + 0.15,
        color: index % 3 == 0
            ? const Color(0xFF4A7C43)
            : index % 3 == 1
                ? const Color(0xFFD4A574)
                : const Color(0xFF6BB3F0),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = (particle.x * size.width +
              animationValue * particle.speed * size.width) %
          size.width;
      final y = (particle.y * size.height -
              animationValue * particle.speed * size.height * 0.5) %
          size.height;

      final glowSize = particle.size * (1 + pulseValue * 0.3);

      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSize * 3);
      canvas.drawCircle(Offset(x, y), glowSize * 2, glowPaint);

      final corePaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSize * 0.5);
      canvas.drawCircle(Offset(x, y), glowSize, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pulseValue != pulseValue;
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

/// Luxury header with glowing effects
class _LuxuryHeader extends StatelessWidget {
  final AnimationController pulseController;
  final VoidCallback onBack;

  const _LuxuryHeader({
    required this.pulseController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          _GlowingBackButton(
            onTap: onBack,
            pulseController: pulseController,
          ),
          SizedBox(height: 20.h),
          // Title section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.secondary,
                      Colors.white,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'حساب جديد',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'أنشئ حسابك وابدأ الطلب',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15.sp,
                    color: Colors.white.withOpacity(0.8),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    final pulseValue = 0.8 + pulseController.value * 0.4;
                    return Container(
                      width: 50.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.r),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withOpacity(0.5),
                            AppColors.secondary,
                            AppColors.secondary.withOpacity(0.5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.secondary.withOpacity(0.6 * pulseValue),
                            blurRadius: 15 * pulseValue,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Glowing back button
class _GlowingBackButton extends StatefulWidget {
  final VoidCallback onTap;
  final AnimationController pulseController;

  const _GlowingBackButton({
    required this.onTap,
    required this.pulseController,
  });

  @override
  State<_GlowingBackButton> createState() => _GlowingBackButtonState();
}

class _GlowingBackButtonState extends State<_GlowingBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: widget.pulseController,
        builder: (context, child) {
          final pulseValue = 0.8 + widget.pulseController.value * 0.4;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(_isPressed ? 0.25 : 0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3 * pulseValue),
                  blurRadius: 15 * pulseValue,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.r,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

/// Glassmorphic form container
class _GlassmorphicFormContainer extends StatelessWidget {
  final Widget child;

  const _GlassmorphicFormContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Luxury section label with glow
class _LuxurySectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final AnimationController pulseController;

  const _LuxurySectionLabel({
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseValue = 0.8 + pulseController.value * 0.4;
        return Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primaryLight.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4 * pulseValue),
                    blurRadius: 10 * pulseValue,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, size: 16.r, color: Colors.white),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
            if (subtitle != null) ...[
              const Spacer(),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11.sp,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Luxury text field with glow effects
class _LuxuryTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String>? onFieldSubmitted;
  final AnimationController pulseController;
  final Widget? suffixIcon;

  const _LuxuryTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.errorText,
    this.onFieldSubmitted,
    required this.pulseController,
    this.suffixIcon,
  });

  @override
  State<_LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<_LuxuryTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        AnimatedBuilder(
          animation: widget.pulseController,
          builder: (context, child) {
            final pulseValue = 0.8 + widget.pulseController.value * 0.4;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4 * pulseValue),
                          blurRadius: 20 * pulseValue,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                maxLength: widget.maxLength,
                textCapitalization: widget.textCapitalization,
                validator: widget.validator,
                onFieldSubmitted: widget.onFieldSubmitted,
                textAlign:
                    widget.obscureText ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  errorText: widget.errorText,
                  errorStyle: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.error,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white.withOpacity(_isFocused ? 0.15 : 0.1),
                  prefixIcon: Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppColors.secondary
                        : Colors.white.withOpacity(0.6),
                    size: 22.r,
                  ),
                  suffixIcon: widget.suffixIcon,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: AppColors.secondary.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: AppColors.error.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Luxury security question field
class _LuxurySecurityQuestionField extends StatefulWidget {
  final String? selectedQuestion;
  final ValueChanged<String?> onQuestionChanged;
  final TextEditingController answerController;
  final FocusNode? answerFocusNode;
  final String? questionError;
  final String? answerError;
  final ValueChanged<String>? onAnswerSubmitted;
  final AnimationController pulseController;

  const _LuxurySecurityQuestionField({
    required this.selectedQuestion,
    required this.onQuestionChanged,
    required this.answerController,
    this.answerFocusNode,
    this.questionError,
    this.answerError,
    this.onAnswerSubmitted,
    required this.pulseController,
  });

  @override
  State<_LuxurySecurityQuestionField> createState() =>
      _LuxurySecurityQuestionFieldState();
}

class _LuxurySecurityQuestionFieldState
    extends State<_LuxurySecurityQuestionField> {
  bool _isDropdownFocused = false;
  bool _isAnswerFocused = false;

  @override
  void initState() {
    super.initState();
    widget.answerFocusNode?.addListener(_onAnswerFocusChange);
  }

  void _onAnswerFocusChange() {
    setState(() => _isAnswerFocused = widget.answerFocusNode?.hasFocus ?? false);
  }

  @override
  void dispose() {
    widget.answerFocusNode?.removeListener(_onAnswerFocusChange);
    super.dispose();
  }

  String? _validateAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'إجابة سؤال الأمان مطلوبة';
    }
    if (value.trim().length < 2) {
      return 'الإجابة يجب أن تكون حرفين على الأقل';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown label
        Text(
          'سؤال الأمان',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Dropdown
        AnimatedBuilder(
          animation: widget.pulseController,
          builder: (context, child) {
            final pulseValue = 0.8 + widget.pulseController.value * 0.4;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: _isDropdownFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4 * pulseValue),
                          blurRadius: 20 * pulseValue,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Focus(
                onFocusChange: (focused) =>
                    setState(() => _isDropdownFocused = focused),
                child: DropdownButtonFormField<String>(
                  value: widget.selectedQuestion,
                  onChanged: widget.onQuestionChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        Colors.white.withOpacity(_isDropdownFocused ? 0.15 : 0.1),
                    prefixIcon: Icon(
                      Icons.shield_outlined,
                      color: _isDropdownFocused
                          ? AppColors.secondary
                          : Colors.white.withOpacity(0.6),
                      size: 22.r,
                    ),
                    hintText: 'اختر سؤال الأمان',
                    hintStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    errorText: widget.questionError,
                    errorStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.error,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.secondary.withOpacity(0.8),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.error.withOpacity(0.8),
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  ),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 24.r,
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(16.r),
                  items: SecurityQuestions.questions.map((question) {
                    return DropdownMenuItem<String>(
                      value: question,
                      child: Text(
                        question,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        // Answer field
        Text(
          'إجابة سؤال الأمان',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        AnimatedBuilder(
          animation: widget.pulseController,
          builder: (context, child) {
            final pulseValue = 0.8 + widget.pulseController.value * 0.4;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: _isAnswerFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4 * pulseValue),
                          blurRadius: 20 * pulseValue,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: widget.answerController,
                focusNode: widget.answerFocusNode,
                validator: _validateAnswer,
                onFieldSubmitted: widget.onAnswerSubmitted,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل إجابتك',
                  hintStyle: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  errorText: widget.answerError,
                  errorStyle: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.error,
                  ),
                  filled: true,
                  fillColor:
                      Colors.white.withOpacity(_isAnswerFocused ? 0.15 : 0.1),
                  prefixIcon: Icon(
                    Icons.key_outlined,
                    color: _isAnswerFocused
                        ? AppColors.secondary
                        : Colors.white.withOpacity(0.6),
                    size: 22.r,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: AppColors.secondary.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: AppColors.error.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Glowing button with animation
class _GlowingButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final AnimationController pulseController;

  const _GlowingButton({
    required this.text,
    required this.icon,
    required this.isLoading,
    this.onPressed,
    required this.pulseController,
  });

  @override
  State<_GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<_GlowingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: widget.pulseController,
        builder: (context, child) {
          final pulseValue = 0.8 + widget.pulseController.value * 0.4;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 56.h,
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDisabled
                    ? [
                        AppColors.primary.withOpacity(0.5),
                        AppColors.primaryLight.withOpacity(0.5),
                      ]
                    : [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
              ),
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5 * pulseValue),
                        blurRadius: 25 * pulseValue,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2 * pulseValue),
                        blurRadius: 40 * pulseValue,
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 22.r,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Login link with glow
class _LoginLink extends StatelessWidget {
  final VoidCallback onTap;

  const _LoginLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'سجل الدخول',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              shadows: [
                Shadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Glowing loader
class _GlowingLoader extends StatelessWidget {
  final AnimationController pulseController;

  const _GlowingLoader({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseValue = 0.8 + pulseController.value * 0.4;
        return Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5 * pulseValue),
                blurRadius: 30 * pulseValue,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3 * pulseValue),
                blurRadius: 50 * pulseValue,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.9),
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 40.r,
                height: 40.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}