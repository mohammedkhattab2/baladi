import 'dart:math' as math;
import 'dart:ui';

import 'package:baladi/core/config/app_config.dart';
import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/extensions.dart';
import 'package:baladi/domain/enums/user_role.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Luxury Welcome Screen with magical animations and glowing effects
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<double> _brandFadeIn;
  late Animation<double> _brandScale;
  late Animation<double> _titleSlide;
  late Animation<double> _cardsSlide;
  late Animation<double> _footerFade;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Background gradient animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Entrance animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Pulse animation for glow effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Floating particles animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Brand section animations
    _brandFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _brandScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _cardsSlide = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
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
                _AnimatedGradientBackground(
                  controller: _backgroundController,
                ),
                // Floating particles
                _FloatingParticles(
                  controller: _floatingController,
                  pulseController: _pulseController,
                ),
                // Main content
                SafeArea(
                  child: AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 60.h),
                              // Brand section with glow
                              _LuxuryBrandSection(
                                fadeIn: _brandFadeIn.value,
                                scale: _brandScale.value,
                                titleOffset: _titleSlide.value,
                                pulseAnimation: _pulseAnimation,
                              ),
                              SizedBox(height: 80.h),
                              // Role selection cards
                              Transform.translate(
                                offset: Offset(0, _cardsSlide.value),
                                child: Opacity(
                                  opacity:
                                      (1 - _cardsSlide.value / 100).clamp(0.0, 1.0),
                                  child: _LuxuryRoleSelection(
                                    onCustomerTap: () =>
                                        context.pushNamed(RouteNames.customerLogin),
                                    onStaffTap: () =>
                                        context.pushNamed(RouteNames.staffLogin),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.h),
                              // Footer
                              Opacity(
                                opacity: _footerFade.value,
                                child: const _LuxuryFooter(),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      );
                    },
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

  static void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final routeName = switch (state.role) {
        UserRole.customer => RouteNames.customerHome,
        UserRole.shop => RouteNames.shopDashboard,
        UserRole.rider => RouteNames.riderDashboard,
        UserRole.admin => RouteNames.adminDashboard,
      };
      context.goNamed(routeName);
    } else if (state is AuthError) {
      context.showErrorSnackBar(state.message);
    }
  }
}

/// Animated gradient background with smooth color transitions
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
      const Color(0xFF0D1B2A), // Deep navy
      const Color(0xFF1B263B), // Dark blue
      const Color(0xFF2D5A27), // Forest green (primary)
      const Color(0xFF1A3A16), // Dark green
      const Color(0xFF0D1B2A), // Back to navy
    ];

    final adjustedT = (t + offset) % 1.0;
    final index = (adjustedT * (colors.length - 1)).floor();
    final localT = (adjustedT * (colors.length - 1)) - index;

    return Color.lerp(colors[index], colors[(index + 1) % colors.length], localT)!;
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
    return List.generate(25, (index) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 0.3 + 0.1,
        opacity: random.nextDouble() * 0.5 + 0.2,
        color: index % 3 == 0
            ? const Color(0xFF4A7C43) // Primary light
            : index % 3 == 1
                ? const Color(0xFFD4A574) // Secondary
                : const Color(0xFF6BB3F0), // Accent blue
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

      // Outer glow
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSize * 3);
      canvas.drawCircle(Offset(x, y), glowSize * 2, glowPaint);

      // Inner core
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

/// Luxury brand section with glowing logo and animated text
class _LuxuryBrandSection extends StatelessWidget {
  final double fadeIn;
  final double scale;
  final double titleOffset;
  final Animation<double> pulseAnimation;

  const _LuxuryBrandSection({
    required this.fadeIn,
    required this.scale,
    required this.titleOffset,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fadeIn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing logo container
          Transform.scale(
            scale: scale,
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 110.r,
                  height: 110.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                    boxShadow: [
                      // Outer glow
                      BoxShadow(
                        color:
                            AppColors.primary.withOpacity(0.4 * pulseAnimation.value),
                        blurRadius: 40 * pulseAnimation.value,
                        spreadRadius: 10 * pulseAnimation.value,
                      ),
                      // Secondary glow
                      BoxShadow(
                        color: AppColors.secondary
                            .withOpacity(0.2 * pulseAnimation.value),
                        blurRadius: 60 * pulseAnimation.value,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withOpacity(0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                            AppColors.secondary,
                          ],
                        ).createShader(bounds),
                        child: Icon(
                          Icons.eco_rounded,
                          size: 48.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 28.h),
          // App name with shimmer effect
          Transform.translate(
            offset: Offset(0, titleOffset),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  AppColors.secondary,
                  Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Text(
                AppConfig.appName,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 42.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                    Shadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Tagline
          Transform.translate(
            offset: Offset(0, titleOffset * 0.5),
            child: Text(
              "توصيل سريع لباب بيتك",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.85),
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Decorative line with glow
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 60.w,
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
                      color: AppColors.secondary
                          .withOpacity(0.6 * pulseAnimation.value),
                      blurRadius: 15 * pulseAnimation.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Luxury role selection with glassmorphism cards
class _LuxuryRoleSelection extends StatelessWidget {
  final VoidCallback onCustomerTap;
  final VoidCallback onStaffTap;

  const _LuxuryRoleSelection({
    required this.onCustomerTap,
    required this.onStaffTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with glow
          Text(
            "اختر طريقة الدخول",
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // Customer card
          _GlassmorphicRoleCard(
            icon: Icons.shopping_bag_outlined,
            title: 'عميل',
            subtitle: 'تصفح المتاجر واطلب للتوصيل',
            gradientColors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primaryLight.withOpacity(0.6),
            ],
            glowColor: AppColors.primary,
            onTap: onCustomerTap,
            delay: 0,
          ),
          SizedBox(height: 16.h),
          // Staff card
          _GlassmorphicRoleCard(
            icon: Icons.badge_outlined,
            title: 'فريق العمل',
            subtitle: 'متجر • سائق توصيل • مدير',
            gradientColors: [
              AppColors.secondary.withOpacity(0.8),
              AppColors.secondaryLight.withOpacity(0.6),
            ],
            glowColor: AppColors.secondary,
            onTap: onStaffTap,
            delay: 100,
          ),
        ],
      ),
    );
  }
}

/// Glassmorphic role selection card with glow effects
class _GlassmorphicRoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;
  final int delay;

  const _GlassmorphicRoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_GlassmorphicRoleCard> createState() => _GlassmorphicRoleCardState();
}

class _GlassmorphicRoleCardState extends State<_GlassmorphicRoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _hoverController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _hoverController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  // Glow effect
                  BoxShadow(
                    color:
                        widget.glowColor.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 25 * _glowAnimation.value,
                    spreadRadius: 2,
                  ),
                  // Soft shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon with gradient background
                        Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: widget.gradientColors,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.glowColor.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 28.r,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Labels
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 18.sp,
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
                              SizedBox(height: 4.h),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 13.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow icon
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ],
                    ),
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

/// Luxury footer with subtle styling
class _LuxuryFooter extends StatelessWidget {
  const _LuxuryFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppConfig.appNameEn,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "الإصدار ${AppConfig.appVersion}",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11.sp,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

/// Glowing loader for loading state
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
                child: CircularProgressIndicator(
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
