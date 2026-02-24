import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/app_notification.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/notification/notification_cubit.dart';
import 'package:baladi/presentation/cubits/notification/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// شاشة إشعارات العميل
///
/// تستخدم نفس منطق [NotificationCubit] مع واجهة متناسقة مع التطبيق.
class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends State<CustomerNotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<NotificationCubit>();
    final state = cubit.state;
    if (state is NotificationLoaded && state.hasMore) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        cubit.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationCubit>()..loadNotifications(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'الإشعارات',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          actions: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded &&
                    state.unreadCount > 0) {
                  return TextButton(
                    onPressed: () =>
                        context.read<NotificationCubit>().markAllAsRead(),
                    child: Text(
                      'تحديد كمقروء',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.sp,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading ||
                state is NotificationInitial) {
              return const Center(child: LoadingWidget());
            }

            if (state is NotificationError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<NotificationCubit>().loadNotifications(),
              );
            }

            List<AppNotification> notifications = [];
            bool loadingMore = false;
            int unread = 0;

            if (state is NotificationLoaded) {
              notifications = state.notifications;
              unread = state.unreadCount;
            } else if (state is NotificationLoadingMore) {
              notifications = state.notifications;
              loadingMore = true;
              unread = state.unreadCount;
            }

            if (notifications.isEmpty) {
              return const AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'لا توجد إشعارات حالياً',
                description:
                    'سيتم إخبارك هنا بالعروض، حالة الطلبات، وأي تحديثات مهمة.',
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<NotificationCubit>().loadNotifications(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: notifications.length + (loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (loadingMore && index == notifications.length) {
                    return Padding(
                      padding: EdgeInsets.all(16.r),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final n = notifications[index];
                  return _NotificationTile(notification: n);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return AppCard(
      margin: EdgeInsets.only(bottom: 8.h),
      onTap: () {
        if (!isRead) {
          context.read<NotificationCubit>().markAsRead(notification.id);
        }
      },
      borderColor: isRead
          ? Colors.transparent
          : AppColors.primary.withOpacity(0.5),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: isRead
                  ? AppColors.primary.withOpacity(0.06)
                  : AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: AppColors.primary,
              size: 20.r,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    fontWeight:
                        isRead ? FontWeight.w500 : FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  notification.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  Formatters.formatRelativeTime(notification.createdAt),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 10.sp,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead) ...[
            SizedBox(width: 6.w),
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}