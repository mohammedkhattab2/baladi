import 'dart:math' as math;
import 'dart:ui';

import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/extensions.dart';
import 'package:baladi/core/utils/validators.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Luxury PIN Recovery Screen with magical animations and glowing effects
class PinRecoveryScreen extends StatefulWidget {
  const PinRecoveryScreen({super.key});

  @override
  State<PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends State<PinRecoveryScreen>
    with TickerProviderStateMixin {
  // Step Tracking: 0 = phone, 1 = answer + new pin, 2 = success
  int _currentStep = 0;

  // Form Keys
  final _phoneFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  // Controllers
  final _phoneController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  // Focus Nodes
  final _phoneFocus = FocusNode();
  final _answerFocus = FocusNode();
  final _newPinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  // Recovery Data
  String _phone = '';
  String _securityQuestion = '';

  // PIN visibility
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _successController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;
  late Animation<double> _contentSlide;
  late Animation<double> _contentFade;

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
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

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

    _contentSlide = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _answerController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _phoneFocus.dispose();
    _answerFocus.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
    _backgroundController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _successController.dispose();
    super.dispose();
  }

  String? _validateAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'إجابة سؤال الأمان مطلوبة';
    }
    return null;
  }

  String? _validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تأكيد رمز الدخول مطلوب';
    }
    if (value.trim() != _newPinController.text.trim()) {
      return 'رمز الدخول غير متطابق';
    }
    return null;
  }

  void _submitPhone(BuildContext blocContext) {
    if (!_phoneFormKey.currentState!.validate()) return;
    FocusScope.of(blocContext).unfocus();

    blocContext.read<AuthCubit>().verifyPhoneForRecovery(
          phone: _phoneController.text.trim(),
        );
  }

  void _submitReset(BuildContext blocContext) {
    if (!_resetFormKey.currentState!.validate()) return;
    FocusScope.of(blocContext).unfocus();

    blocContext.read<AuthCubit>().resetPin(
          phone: _phone,
          securityAnswer: _answerController.text.trim(),
          newPin: _newPinController.text.trim(),
        );
  }

  void _animateToNextStep() {
    _entranceController.reset();
    _entranceController.forward();
  }

  String get _headerTitle => switch (_currentStep) {
        0 => 'استعادة رمز الدخول',
        1 => 'التحقق من الهوية',
        _ => 'تم بنجاح!',
      };

  String get _headerSubtitle => switch (_currentStep) {
        0 => 'أدخل رقم هاتفك المسجل',
        1 => 'أجب على سؤال الأمان وأدخل رمز جديد',
        _ => 'تم تغيير رمز الدخول',
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _onStateChanged,
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
                                  title: _headerTitle,
                                  subtitle: _headerSubtitle,
                                  showBackButton: _currentStep < 2,
                                  pulseController: _pulseController,
                                  onBack: () {
                                    if (_currentStep == 1) {
                                      setState(() => _currentStep = 0);
                                      _animateToNextStep();
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Step Indicator
                            if (_currentStep < 2)
                              Transform.translate(
                                offset: Offset(0, _contentSlide.value * 0.5),
                                child: Opacity(
                                  opacity: _contentFade.value,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.w),
                                    child: _LuxuryStepIndicator(
                                      currentStep: _currentStep,
                                      totalSteps: 2,
                                      pulseController: _pulseController,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 24.h),
                            // Step Content
                            Transform.translate(
                              offset: Offset(0, _contentSlide.value),
                              child: Opacity(
                                opacity: _contentFade.value,
                                child: _currentStep == 0
                                    ? _PhoneStep(
                                        formKey: _phoneFormKey,
                                        phoneController: _phoneController,
                                        phoneFocus: _phoneFocus,
                                        isLoading: isLoading,
                                        onSubmit: () => _submitPhone(context),
                                        onBack: () =>
                                            Navigator.of(context).pop(),
                                        pulseController: _pulseController,
                                      )
                                    : _currentStep == 1
                                        ? _ResetStep(
                                            formKey: _resetFormKey,
                                            securityQuestion: _securityQuestion,
                                            answerController: _answerController,
                                            answerFocus: _answerFocus,
                                            newPinController: _newPinController,
                                            newPinFocus: _newPinFocus,
                                            confirmPinController:
                                                _confirmPinController,
                                            confirmPinFocus: _confirmPinFocus,
                                            validateAnswer: _validateAnswer,
                                            validateConfirmPin:
                                                _validateConfirmPin,
                                            isLoading: isLoading,
                                            onSubmit: () =>
                                                _submitReset(context),
                                            onBack: () {
                                              setState(() => _currentStep = 0);
                                              _animateToNextStep();
                                            },
                                            pulseController: _pulseController,
                                            obscureNewPin: _obscureNewPin,
                                            obscureConfirmPin:
                                                _obscureConfirmPin,
                                            onToggleNewPin: () => setState(() =>
                                                _obscureNewPin =
                                                    !_obscureNewPin),
                                            onToggleConfirmPin: () => setState(
                                                () => _obscureConfirmPin =
                                                    !_obscureConfirmPin),
                                          )
                                        : _SuccessStep(
                                            onBackToLogin: () =>
                                                Navigator.of(context).pop(),
                                            pulseController: _pulseController,
                                            successController:
                                                _successController,
                                          ),
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

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state is AuthRecoveryQuestionLoaded) {
      setState(() {
        _phone = state.phone;
        _securityQuestion = state.securityQuestion;
        _currentStep = 1;
      });
      _animateToNextStep();
    } else if (state is AuthPinResetSuccess) {
      setState(() => _currentStep = 2);
      _animateToNextStep();
      _successController.forward();
    } else if (state is AuthError) {
      context.showErrorSnackBar(state.message);
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
        ..color = particle.color.withValues(alpha:  particle.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSize * 3);
      canvas.drawCircle(Offset(x, y), glowSize * 2, glowPaint);

      final corePaint = Paint()
        ..color = particle.color.withValues(alpha:  particle.opacity * 0.8)
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
  final String title;
  final String subtitle;
  final bool showBackButton;
  final AnimationController pulseController;
  final VoidCallback onBack;

  const _LuxuryHeader({
    required this.title,
    required this.subtitle,
    required this.showBackButton,
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
          if (showBackButton)
            _GlowingBackButton(
              onTap: onBack,
              pulseController: pulseController,
            )
          else
            SizedBox(height: 44.r),
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
                    title,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withValues(alpha:  0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha:  0.8),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha:  0.3),
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

/// Luxury step indicator with glow
class _LuxuryStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final AnimationController pulseController;

  const _LuxuryStepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseValue = 0.8 + pulseController.value * 0.4;
        return Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              // Line connector
              final isActive = (index ~/ 2) < currentStep;
              return Expanded(
                child: Container(
                  height: 3.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.r),
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          )
                        : null,
                    color: isActive ? null : Colors.white.withOpacity(0.2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.primary.withOpacity(0.5 * pulseValue),
                              blurRadius: 10 * pulseValue,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                ),
              );
            }

            // Step dot
            final stepIndex = index ~/ 2;
            final isActive = stepIndex <= currentStep;
            final isCurrent = stepIndex == currentStep;

            return Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      )
                    : null,
                color: isActive ? null : Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.5)
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primary.withOpacity(0.5 * pulseValue),
                          blurRadius: 20 * pulseValue,
                          spreadRadius: 3,
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              ),
            );
          }),
        );
      },
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

/// Luxury info banner
class _LuxuryInfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final AnimationController pulseController;

  const _LuxuryInfoBanner({
    required this.icon,
    required this.text,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseValue = 0.8 + pulseController.value * 0.4;
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.info.withOpacity(0.2),
                AppColors.info.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: AppColors.info.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.info.withOpacity(0.2 * pulseValue),
                blurRadius: 15 * pulseValue,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.info.withOpacity(0.3),
                ),
                child: Icon(icon, color: Colors.white, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Luxury text field
class _LuxuryTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final AnimationController pulseController;
  final Widget? suffixIcon;

  const _LuxuryTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.obscureText = false,
    this.validator,
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

/// Glowing button
class _GlowingButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final AnimationController pulseController;

  const _GlowingButton({
    required this.text,
    this.icon,
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
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 22.r,
                          ),
                          SizedBox(width: 10.w),
                        ],
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

/// Step 1: Phone input
class _PhoneStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final AnimationController pulseController;

  const _PhoneStep({
    required this.formKey,
    required this.phoneController,
    required this.phoneFocus,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassmorphicFormContainer(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LuxuryInfoBanner(
              icon: Icons.phone_outlined,
              text: 'أدخل رقم الهاتف المسجل به حسابك وسنعرض لك سؤال الأمان.',
              pulseController: pulseController,
            ),
            SizedBox(height: 28.h),
            _LuxuryTextField(
              controller: phoneController,
              focusNode: phoneFocus,
              label: 'رقم الهاتف',
              hint: '01xxxxxxxxx',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              validator: Validators.validatePhone,
              onFieldSubmitted: (_) => onSubmit(),
              pulseController: pulseController,
            ),
            SizedBox(height: 32.h),
            _GlowingButton(
              text: 'التالي',
              icon: Icons.arrow_back_rounded,
              isLoading: isLoading,
              onPressed: isLoading ? null : onSubmit,
              pulseController: pulseController,
            ),
            SizedBox(height: 16.h),
            Center(
              child: GestureDetector(
                onTap: onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.r,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'العودة لتسجيل الدخول',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 2: Answer + New PIN
class _ResetStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String securityQuestion;
  final TextEditingController answerController;
  final FocusNode answerFocus;
  final TextEditingController newPinController;
  final FocusNode newPinFocus;
  final TextEditingController confirmPinController;
  final FocusNode confirmPinFocus;
  final String? Function(String?) validateAnswer;
  final String? Function(String?) validateConfirmPin;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final AnimationController pulseController;
  final bool obscureNewPin;
  final bool obscureConfirmPin;
  final VoidCallback onToggleNewPin;
  final VoidCallback onToggleConfirmPin;

  const _ResetStep({
    required this.formKey,
    required this.securityQuestion,
    required this.answerController,
    required this.answerFocus,
    required this.newPinController,
    required this.newPinFocus,
    required this.confirmPinController,
    required this.confirmPinFocus,
    required this.validateAnswer,
    required this.validateConfirmPin,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
    required this.pulseController,
    required this.obscureNewPin,
    required this.obscureConfirmPin,
    required this.onToggleNewPin,
    required this.onToggleConfirmPin,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassmorphicFormContainer(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Security Question Display
            _SecurityQuestionCard(
              question: securityQuestion,
              pulseController: pulseController,
            ),
            SizedBox(height: 20.h),
            // Answer Field
            _LuxuryTextField(
              controller: answerController,
              focusNode: answerFocus,
              label: 'إجابتك',
              hint: 'أدخل إجابة سؤال الأمان',
              prefixIcon: Icons.key_outlined,
              validator: validateAnswer,
              onFieldSubmitted: (_) => newPinFocus.requestFocus(),
              pulseController: pulseController,
            ),
            SizedBox(height: 28.h),
            // New PIN Section Label
            _SectionLabel(
              icon: Icons.lock_reset_outlined,
              label: 'رمز الدخول الجديد',
              pulseController: pulseController,
            ),
            SizedBox(height: 16.h),
            _LuxuryTextField(
              controller: newPinController,
              focusNode: newPinFocus,
              label: 'رمز الدخول الجديد',
              hint: '••••',
              prefixIcon: Icons.lock_outlined,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: obscureNewPin,
              validator: Validators.validatePin,
              onFieldSubmitted: (_) => confirmPinFocus.requestFocus(),
              pulseController: pulseController,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureNewPin
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 22.r,
                ),
                onPressed: onToggleNewPin,
              ),
            ),
            SizedBox(height: 16.h),
            _LuxuryTextField(
              controller: confirmPinController,
              focusNode: confirmPinFocus,
              label: 'تأكيد رمز الدخول',
              hint: '••••',
              prefixIcon: Icons.lock_outlined,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: obscureConfirmPin,
              validator: validateConfirmPin,
              onFieldSubmitted: (_) => onSubmit(),
              pulseController: pulseController,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPin
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 22.r,
                ),
                onPressed: onToggleConfirmPin,
              ),
            ),
            SizedBox(height: 32.h),
            _GlowingButton(
              text: 'تغيير رمز الدخول',
              icon: Icons.lock_reset_outlined,
              isLoading: isLoading,
              onPressed: isLoading ? null : onSubmit,
              pulseController: pulseController,
            ),
            SizedBox(height: 16.h),
            Center(
              child: GestureDetector(
                onTap: onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.r,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'تغيير رقم الهاتف',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Security question card
class _SecurityQuestionCard extends StatelessWidget {
  final String question;
  final AnimationController pulseController;

  const _SecurityQuestionCard({
    required this.question,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseValue = 0.8 + pulseController.value * 0.4;
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary.withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2 * pulseValue),
                blurRadius: 15 * pulseValue,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
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
                child: Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سؤال الأمان',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      question,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Section label
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final AnimationController pulseController;

  const _SectionLabel({
    required this.icon,
    required this.label,
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
          ],
        );
      },
    );
  }
}

/// Step 3: Success
class _SuccessStep extends StatelessWidget {
  final VoidCallback onBackToLogin;
  final AnimationController pulseController;
  final AnimationController successController;

  const _SuccessStep({
    required this.onBackToLogin,
    required this.pulseController,
    required this.successController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          // Success Icon with glow
          AnimatedBuilder(
            animation: Listenable.merge([pulseController, successController]),
            builder: (context, child) {
              final pulseValue = 0.8 + pulseController.value * 0.4;
              final scaleValue = Curves.elasticOut.transform(
                successController.value.clamp(0.0, 1.0),
              );
              return Transform.scale(
                scale: scaleValue,
                child: Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.success.withOpacity(0.3),
                        AppColors.success.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5 * pulseValue),
                        blurRadius: 40 * pulseValue,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.success,
                          AppColors.success.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 48.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 32.h),
          // Success text
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white,
                AppColors.success,
                Colors.white,
              ],
            ).createShader(bounds),
            child: Text(
              'تم تغيير رمز الدخول بنجاح',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'يمكنك الآن تسجيل الدخول\nبرمز الدخول الجديد',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15.sp,
              height: 1.6,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48.h),
          // Login button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _GlowingButton(
              text: 'تسجيل الدخول',
              icon: Icons.login_rounded,
              isLoading: false,
              onPressed: onBackToLogin,
              pulseController: pulseController,
            ),
          ),
        ],
      ),
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