// lib/presentation/features/admin/screens/admin_dashboard_screen.dart

import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/weekly_period.dart';
import 'package:baladi/domain/repositories/admin_repository.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/admin/admin_cubit.dart';
import 'package:baladi/presentation/cubits/admin/admin_state.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:baladi/presentation/features/admin/widgets/admin_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadDashboard(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: RouteNames.adminDashboard,
      title: 'لوحة التحكم',
      child: Container(
        decoration: const BoxDecoration(
          // نفس الجريدينت العميق المستخدم في هوية Baladi (welcome / admin)
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF2D5A27),
              Color(0xFF1A3A16),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // أوربز إضاءة ناعمة في الخلفية عشان تحس إنها نفس العالم البصري
            Positioned(
              top: -80,
              left: -40,
              child: _GlowOrb(
                size: 180,
                color: AppColors.primary,
                opacity: 0.22,
              ),
            ),
            Positioned(
              bottom: -60,
              right: -30,
              child: _GlowOrb(
                size: 160,
                color: AppColors.secondary,
                opacity: 0.20,
              ),
            ),
            BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminWeekClosed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      content: Text(
                        'تم إغلاق الفترة بنجاح: ${state.closedPeriod.displayLabel}',
                        style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Reload dashboard after closing week
                  context.read<AdminCubit>().loadDashboard();
                }
                if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      content: Text(
                        state.message,
                        style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: LoadingWidget());
                }
                if (state is AdminActionLoading) {
                  return const Center(
                    child: LoadingWidget(message: 'جاري المعالجة...'),
                  );
                }
                if (state is AdminError) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 520.w),
                      child: AppErrorWidget(
                        message: state.message,
                        onRetry: () =>
                            context.read<AdminCubit>().loadDashboard(),
                      ),
                    ),
                  );
                }
                if (state is AdminDashboardLoaded) {
                  return _DashboardContent(dashboard: state.dashboard);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final AdminDashboard dashboard;

  const _DashboardContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AdminCubit>().loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _WelcomeCard(currentPeriod: dashboard.currentPeriod),
            SizedBox(height: 24.h),

            // Stats Section
            _SectionHeader(
              title: 'الإحصائيات',
              trailing: Text(
                'إجمالي المستخدمين: ${Formatters.formatNumber(dashboard.totalUsers)}',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _StatsGrid(dashboard: dashboard),
            SizedBox(height: 24.h),

            // Orders health section (from architecture: حالة الطلبات + تنبيه مبسط)
            _SectionHeader(title: 'حالة الطلبات'),
            SizedBox(height: 12.h),
            _OrdersStatusRow(dashboard: dashboard),
            SizedBox(height: 16.h),
            _RevenueSummaryCard(dashboard: dashboard),
            SizedBox(height: 24.h),

            // Quick Actions Section
            _SectionHeader(title: 'إجراءات سريعة'),
            SizedBox(height: 12.h),
            _QuickActionsSection(dashboard: dashboard),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final WeeklyPeriod? currentPeriod;

  const _WelcomeCard({this.currentPeriod});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1722),
            Color(0xFF132433),
          ],
        ),
        border: Border.all(
          color: Colors.white24,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.55),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك في لوحة التحكم 👋',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'إدارة نظام بلدي للتوصيل',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (currentPeriod != null) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: AppColors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.40),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18.r,
                    height: 18.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 11.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'الفترة الحالية: ${Formatters.formatDate(currentPeriod!.startDate)} - ${Formatters.formatDate(currentPeriod!.endDate)}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        if (trailing != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontFamily: AppTextStyles.fontFamily,
            ),
            child: trailing!,
          ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AdminDashboard dashboard;

  const _StatsGrid({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.people,
                color: AppColors.primary,
                value: Formatters.formatNumber(dashboard.totalCustomers),
                label: 'العملاء',
                onTap: () => context.goNamed(RouteNames.adminUsers),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.storefront,
                color: AppColors.secondary,
                value: Formatters.formatNumber(dashboard.totalShops),
                label: 'المحلات',
                onTap: () => context.goNamed(RouteNames.adminShops),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.delivery_dining,
                color: AppColors.info,
                value: Formatters.formatNumber(dashboard.totalRiders),
                label: 'السائقين',
                onTap: () => context.goNamed(RouteNames.adminRiders),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.receipt_long,
                color: AppColors.success,
                value: Formatters.formatNumber(dashboard.totalOrders),
                label: 'إجمالي الطلبات',
                onTap: () => context.goNamed(RouteNames.adminOrders),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.account_balance_wallet,
                color: AppColors.warning,
                value: Formatters.formatCurrency(dashboard.totalRevenue),
                label: 'إيرادات المنصة (الأسبوع الحالي)',
                onTap: () => context.goNamed(RouteNames.adminSettlements),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.stars,
                color: Colors.purple,
                value: Formatters.formatNumber(
                  dashboard.totalPointsIssued - dashboard.totalPointsRedeemed,
                ),
                label: 'النقاط النشطة',
                onTap: () => context.goNamed(RouteNames.adminPoints),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// تبويب مبسط لحالة الطلبات الحالية (مستوحى من الـ Architecture: Alerts + Order Monitoring)
class _OrdersStatusRow extends StatelessWidget {
  final AdminDashboard dashboard;

  const _OrdersStatusRow({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final int activeOrders =
        dashboard.totalOrders - dashboard.completedOrders - dashboard.cancelledOrders;

    return Row(
      children: [
        Expanded(
          child: AdminStatCard(
            icon: Icons.pending_actions,
            color: AppColors.statusPending,
            value: Formatters.formatNumber(activeOrders),
            label: 'طلبات نشطة',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AdminStatCard(
            icon: Icons.check_circle_outline,
            color: AppColors.statusCompleted,
            value: Formatters.formatNumber(dashboard.completedOrders),
            label: 'طلبات مكتملة',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AdminStatCard(
            icon: Icons.cancel_outlined,
            color: AppColors.statusCancelled,
            value: Formatters.formatNumber(dashboard.cancelledOrders),
            label: 'طلبات ملغاة',
          ),
        ),
      ],
    );
  }
}

/// كارت يلخص أداء الفترة الحالية (Requests + Revenue) كما هو موضح في Admin Dashboard بالـ Architecture
class _RevenueSummaryCard extends StatelessWidget {
  final AdminDashboard dashboard;

  const _RevenueSummaryCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final int activeOrders =
        dashboard.totalOrders - dashboard.completedOrders - dashboard.cancelledOrders;
 
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF050B11),
            Color(0xFF101B27),
          ],
        ),
        border: Border.all(
          color: Colors.white24,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الفترة الحالية',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          if (dashboard.currentPeriod != null)
            Text(
              '${dashboard.currentPeriod!.displayLabel} • '
              '${Formatters.formatDate(dashboard.currentPeriod!.startDate)} - ${Formatters.formatDate(dashboard.currentPeriod!.endDate)}',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          if (dashboard.currentPeriod != null) SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 18.r,
                color: Colors.white70,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'إجمالي الطلبات: ${Formatters.formatNumber(dashboard.totalOrders)} '
                  '• المكتملة: ${Formatters.formatNumber(dashboard.completedOrders)} '
                  '• الملغاة: ${Formatters.formatNumber(dashboard.cancelledOrders)} '
                  '• النشطة الآن: ${Formatters.formatNumber(activeOrders)}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18.r,
                color: Colors.white70,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'إيرادات المنصة في هذه الفترة: ${Formatters.formatCurrency(dashboard.totalRevenue)}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final AdminDashboard dashboard;

  const _QuickActionsSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final activeOrders =
        dashboard.totalOrders -
        dashboard.completedOrders -
        dashboard.cancelledOrders;

    return Column(
      children: [
        _QuickActionTile(
          icon: Icons.calendar_month,
          label: 'إغلاق الفترة الحالية',
          subtitle: 'إنشاء تسويات جديدة',
          onTap: () => _showCloseWeekDialog(context),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.date_range_outlined,
          label: 'فترات التسوية',
          subtitle: 'عرض جميع الفترات',
          onTap: () => context.goNamed(RouteNames.adminPeriods),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.category_outlined,
          label: 'إدارة الأقسام',
          subtitle: 'إضافة وتعديل أقسام المحلات',
          onTap: () => context.goNamed(RouteNames.adminCategories),
        ),
      ],
    );
  }

  void _showCloseWeekDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'إغلاق الفترة الحالية',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'سيتم إنشاء تسويات لجميع المحلات والسائقين.\n\nهل أنت متأكد؟',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().closeCurrentWeek();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'إغلاق الفترة',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
 
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.95),
                        AppColors.primary.withValues(alpha: 0.75),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.55),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22.r),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left,
                  color: Colors.white.withValues(alpha: 0.55),
                  size: 24.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
/// Soft glowing background orb for admin dashboard (matches admin categories)
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
 
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: size / 2,
            spreadRadius: size / 6,
          ),
        ],
      ),
    );
  }
}