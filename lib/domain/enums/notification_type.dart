// Domain - Notification type enumeration.
//
// Categorizes push/in-app notifications for routing and display.

/// Types of notifications sent to users.
enum NotificationType {
  /// New order placed (sent to shop).
  orderNew('order_new', 'طلب جديد'),

  /// Order accepted by shop (sent to customer).
  orderAccepted('order_accepted', 'تم قبول الطلب'),

  /// Order is being prepared (sent to customer).
  orderPreparing('order_preparing', 'جاري التحضير'),

  /// Order picked up by rider (sent to customer).
  orderPickedUp('order_picked_up', 'تم استلام الطلب'),

  /// Order delivered (sent to customer/shop).
  orderDelivered('order_delivered', 'تم التوصيل'),

  /// Order completed (sent to customer).
  orderCompleted('order_completed', 'تم إكمال الطلب'),

  /// Order cancelled (sent to relevant parties).
  orderCancelled('order_cancelled', 'تم إلغاء الطلب'),

  /// Points earned from order (sent to customer).
  pointsEarned('points_earned', 'نقاط مكتسبة'),

  /// Referral bonus awarded (sent to referrer).
  referralBonus('referral_bonus', 'مكافأة إحالة'),

  /// Weekly settlement ready (sent to shop/rider).
  settlementReady('settlement_ready', 'التسوية جاهزة'),

  /// New delivery available (sent to rider).
  deliveryAvailable('delivery_available', 'توصيل متاح'),

  /// General system notification.
  system('system', 'إشعار النظام');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const NotificationType(this.value, this.labelAr);

  /// Creates a [NotificationType] from its backend string [value].
  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }

  /// Returns `true` if this notification is order-related.
  bool get isOrderRelated => value.startsWith('order_');
}