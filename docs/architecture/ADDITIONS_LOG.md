# Baladi — Architecture Additions Log

## Summary

After a full audit of the existing codebase against the three architecture documents
(`BALADI_ARCHITECTURE.md`, `BALADI_MVP_ARCHITECTURE.md`, `IMPLEMENTATION_PLAN.md`),
the following files were **created** or **modified** to fill gaps in the
**core**, **domain**, and **cubit (presentation)** layers.

---

## 1. Domain — New Enum Files

| # | File | Purpose |
|---|------|---------|
| 1 | [`lib/domain/enums/ad_type.dart`](../../lib/domain/enums/ad_type.dart) | `AdType` enum (`dailyOffer`, `banner`, `featured`) matching the `ads.ad_type` DB column. |
| 2 | [`lib/domain/enums/vehicle_type.dart`](../../lib/domain/enums/vehicle_type.dart) | `VehicleType` enum (`bicycle`, `motorcycle`, `car`) matching the `riders.vehicle_type` DB column. |
| 3 | [`lib/domain/enums/cash_transaction_type.dart`](../../lib/domain/enums/cash_transaction_type.dart) | `CashTransactionType` enum (`customerToRider`, `riderToShop`, `shopToAdmin`) for cash flow tracking. |
| 4 | [`lib/domain/enums/points_transaction_type.dart`](../../lib/domain/enums/points_transaction_type.dart) | `PointsTransactionType` enum (`earned`, `redeemed`, `referral`, `adjustment`) with `isCredit`/`isDebit` helpers and `value` getter. |
| 5 | [`lib/domain/enums/referral_status.dart`](../../lib/domain/enums/referral_status.dart) | `ReferralStatus` enum (`pending`, `completed`, `expired`) for referral lifecycle tracking. |

---

## 2. Domain — New Entity Files

| # | File | Purpose |
|---|------|---------|
| 1 | [`lib/domain/entities/referral.dart`](../../lib/domain/entities/referral.dart) | `Referral` entity with `referrerId`, `referredId`, `referralCode`, `firstOrderId`, `pointsAwarded`, `status`, timestamps. Maps to the `referrals` DB table. |
| 2 | [`lib/domain/entities/cash_transaction.dart`](../../lib/domain/entities/cash_transaction.dart) | `CashTransaction` entity with `orderId`, `type`, `amount`, `fromUserId`, `toUserId`, `confirmedAt`, `confirmedBy`. Maps to the `cash_transactions` DB table. |
| 3 | [`lib/domain/entities/audit_log.dart`](../../lib/domain/entities/audit_log.dart) | `AuditLog` entity with `userId`, `action`, `entityType`, `entityId`, `details`, `createdAt`. Maps to the `audit_logs` DB table. |
| 4 | [`lib/domain/entities/order_status_history.dart`](../../lib/domain/entities/order_status_history.dart) | `OrderStatusHistory` entity with `orderId`, `status`, `changedBy`, `notes`, `createdAt`. Maps to the `order_status_history` DB table. |

---

## 3. Domain — New Business Rules Files

| # | File | Purpose |
|---|------|---------|
| 1 | [`lib/domain/rules/settlement_rules.dart`](../../lib/domain/rules/settlement_rules.dart) | `SettlementRules` — pure Dart static class with week boundary calculations (Saturday–Friday Cairo time), shop net amount calculation (`grossSales - totalCommission`), admin net commission (`totalCommission - pointsDiscounts - freeDeliveryCosts`), and period validation helpers. |
| 2 | [`lib/domain/rules/referral_rules.dart`](../../lib/domain/rules/referral_rules.dart) | `ReferralRules` — pure Dart static class with referral code generation (6-char alphanumeric), referral code validation, referral bonus points constant (2 points), and self-referral prevention check. |

---

## 4. Domain — New Service Files

| # | File | Purpose |
|---|------|---------|
| 1 | [`lib/domain/services/settlement_calculator.dart`](../../lib/domain/services/settlement_calculator.dart) | `SettlementCalculator` injectable service wrapping `SettlementRules` and `CommissionRules`. Contains `ShopSettlementSummary`, `RiderSettlementSummary`, and `AdminSettlementSummary` value objects. Provides `calculateShopSettlement()`, `calculateRiderSettlement()`, and `calculateAdminSummary()` methods. |

---

## 5. Domain — New Use Case Files

| # | File | Purpose |
|---|------|---------|
| 1 | [`lib/domain/usecases/points/redeem_points.dart`](../../lib/domain/usecases/points/redeem_points.dart) | `RedeemPoints` use case — validates points using `PointsCalculator`, then calls `PointsRepository.redeemPoints()`. Uses `RedeemPointsParams` (Equatable) with `customerId`, `orderId`, `points`, `platformCommission`. |
| 2 | [`lib/domain/usecases/rider/accept_delivery.dart`](../../lib/domain/usecases/rider/accept_delivery.dart) | `AcceptDelivery` use case — rider accepts a delivery by calling `OrderRepository.markPickedUp()`. Uses `AcceptDeliveryParams` with `orderId`. |
| 3 | [`lib/domain/usecases/rider/get_rider_earnings.dart`](../../lib/domain/usecases/rider/get_rider_earnings.dart) | `GetRiderEarnings` use case — fetches rider total earnings via `RiderRepository.getTotalEarnings()`. Uses `NoParams`. |
| 4 | [`lib/domain/usecases/shop/toggle_shop_status.dart`](../../lib/domain/usecases/shop/toggle_shop_status.dart) | `ToggleShopStatus` use case — toggles shop open/closed via `ShopRepository.updateShopStatus()`. Uses `ToggleShopStatusParams` with `isOpen`. |
| 5 | [`lib/domain/usecases/shop/confirm_cash_received.dart`](../../lib/domain/usecases/shop/confirm_cash_received.dart) | `ConfirmCashReceived` use case — shop confirms cash from rider via `OrderRepository.confirmCashReceived()`. Uses `ConfirmCashReceivedParams` with `orderId`. |
| 6 | [`lib/domain/usecases/admin/manage_users.dart`](../../lib/domain/usecases/admin/manage_users.dart) | Two use cases: `GetUsers` (paginated user list with optional role filter) and `ToggleUserStatus` (activate/deactivate a user). Uses `GetUsersParams` and `ToggleUserStatusParams`. |
| 7 | [`lib/domain/usecases/admin/settle_period.dart`](../../lib/domain/usecases/admin/settle_period.dart) | `GetShopSettlementDetail` use case — fetches a single shop settlement by ID for admin review. Uses `GetShopSettlementDetailParams`. |
| 8 | [`lib/domain/usecases/admin/get_settlement_report.dart`](../../lib/domain/usecases/admin/get_settlement_report.dart) | `GetSettlementReport` use case — aggregates shop + rider settlements into a `SettlementReport` value object with totals for `grossSales`, `commissions`, `deliveryFees`, `pointsDiscounts`, `freeDeliveryCosts`, `adsRevenue`, `adminNetRevenue`. |

---

## 6. Domain — Modified Repository Interfaces

| # | File | Change |
|---|------|--------|
| 1 | [`lib/domain/repositories/points_repository.dart`](../../lib/domain/repositories/points_repository.dart) | Added `redeemPoints({required String customerId, required String orderId, required int points})` returning `Future<Result<void>>`. |

---

## 7. Core — Modified Files

| # | File | Change |
|---|------|--------|
| 1 | [`lib/core/network/api_endpoints.dart`](../../lib/core/network/api_endpoints.dart) | Added `static const String customerPointsRedeem = '/customer/points/redeem';` endpoint constant. |

---

## 8. Data — Modified Files

| # | File | Change |
|---|------|--------|
| 1 | [`lib/data/repositories/points_repository_impl.dart`](../../lib/data/repositories/points_repository_impl.dart) | Added `redeemPoints()` implementation (delegates to remote datasource). Fixed return type from `Result<bool>` to `Result<void>` to match the domain interface. |
| 2 | [`lib/data/datasources/remote/points_remote_datasource.dart`](../../lib/data/datasources/remote/points_remote_datasource.dart) | Added `redeemPoints({required String customerId, required String orderId, required int points})` abstract method and implementation using `ApiEndpoints.customerPointsRedeem`. |

---

## 9. Presentation — New Cubit Files

| # | File | Purpose |
|---|------|---------|
| 1 | [`lib/presentation/cubits/checkout/checkout_state.dart`](../../lib/presentation/cubits/checkout/checkout_state.dart) | Sealed `CheckoutState` hierarchy: `CheckoutInitial`, `CheckoutCalculating`, `CheckoutSummaryLoaded` (with `copyWith`), `CheckoutPlacingOrder`, `CheckoutOrderPlaced`, `CheckoutError`. |
| 2 | [`lib/presentation/cubits/checkout/checkout_cubit.dart`](../../lib/presentation/cubits/checkout/checkout_cubit.dart) | `CheckoutCubit` — manages checkout flow using `PlaceOrder`, `GetPointsBalance`, `PointsCalculator`, `CommissionCalculator`. Methods: `initCheckout()`, `updatePointsToRedeem()`, `updateDeliveryAddress()`, `updateCustomerNotes()`, `placeOrder()`, `reset()`. NO business calculations — all delegated to domain services. |
| 3 | [`lib/presentation/cubits/settlement/settlement_state.dart`](../../lib/presentation/cubits/settlement/settlement_state.dart) | Sealed `SettlementState` hierarchy: `SettlementInitial`, `SettlementLoading`, `SettlementPeriodsLoaded`, `SettlementReportLoaded`, `ShopSettlementDetailLoaded`, `RiderSettlementDetailLoaded`, `SettlementWeekClosed`, `SettlementError`. |
| 4 | [`lib/presentation/cubits/settlement/settlement_cubit.dart`](../../lib/presentation/cubits/settlement/settlement_cubit.dart) | `SettlementCubit` — manages settlement screens using `SettlementRepository`, `GetSettlementReport`, `GetShopSettlementDetail`, `CloseWeek`. Methods: `loadPeriods()`, `loadReport()`, `loadShopSettlementDetail()`, `loadRiderSettlementDetail()`, `closeCurrentWeek()`, `reset()`. |

---

## 10. Architecture Compliance Summary

### What was already present (no changes needed):

**Core layer:**
- `core/error/exceptions.dart` — `AppException` hierarchy ✅
- `core/error/failures.dart` — `Failure` hierarchy with `Failure.fromException()` ✅
- `core/result/result.dart` — Sealed `Result<T>` with `Success`, `ResultFailure` ✅
- `core/usecase/usecase.dart` — Abstract `UseCase<T, Params>` + `NoParams` ✅
- `core/config/environment.dart` — `EnvironmentConfig` (dev/staging/prod) ✅
- `core/config/app_config.dart` — App-wide configuration ✅
- `core/network/api_client.dart` — HTTP client with token injection, logging, error mapping ✅
- `core/network/api_endpoints.dart` — All API endpoint paths ✅
- `core/network/api_response.dart` — Standardized API response wrapper ✅
- `core/network/network_info.dart` — Connectivity checking ✅
- `core/di/injection.dart` — Injectable setup ✅
- `core/utils/validators.dart`, `formatters.dart`, `helpers.dart`, `extensions.dart` ✅
- `core/services/cache_service.dart`, `local_storage_service.dart`, `notification_service.dart`, `secure_storage_service.dart` ✅
- `core/theme/app_colors.dart`, `app_text_styles.dart`, `app_theme.dart` ✅
- `core/router/app_router.dart`, `route_names.dart` ✅

**Domain layer (already existing):**
- All main entities: `user`, `customer`, `shop`, `rider`, `product`, `order`, `order_item`, `category`, `ad`, `app_notification`, `points_transaction`, `shop_settlement`, `rider_settlement`, `weekly_period` ✅
- All main enums: `user_role`, `order_status`, `payment_method`, `notification_type`, `period_status`, `settlement_status` ✅
- All business rules: `points_rules`, `commission_rules`, `order_rules`, `discount_rules` ✅
- All domain services: `points_calculator`, `commission_calculator`, `order_validator`, `discount_applier` ✅
- All repository interfaces: `auth_repository`, `order_repository`, `customer_repository`, `shop_repository`, `rider_repository`, `product_repository`, `category_repository`, `points_repository`, `settlement_repository`, `admin_repository`, `ad_repository`, `notification_repository` ✅
- Core use cases: `login_customer`, `login_user`, `register_customer`, `recover_pin`, `logout`, `get_categories`, `get_category_shops`, `get_shop_products`, `get_profile`, `update_profile`, `update_address`, `apply_referral`, `place_order`, `get_orders`, `get_order_details`, `update_order_status`, `cancel_order`, `get_points_balance`, `get_points_history`, `get_shop_dashboard`, `get_shop_orders`, `get_shop_settlements`, `manage_product`, `get_available_orders`, `get_rider_dashboard`, `get_rider_orders`, `toggle_availability`, `get_admin_dashboard`, `adjust_points`, `close_week` ✅

**Presentation layer (already existing cubits):**
- `auth/auth_cubit.dart` + `auth_state.dart` ✅
- `cart/cart_cubit.dart` + `cart_state.dart` ✅
- `catalog/categories_cubit.dart` + `categories_state.dart` ✅
- `catalog/shop_products_cubit.dart` + `shop_products_state.dart` ✅
- `customer/customer_profile_cubit.dart` + `customer_profile_state.dart` ✅
- `order/order_cubit.dart` + `order_state.dart` ✅
- `points/points_cubit.dart` + `points_state.dart` ✅
- `shop/shop_management_cubit.dart` + `shop_management_state.dart` ✅
- `rider/rider_cubit.dart` + `rider_state.dart` ✅
- `admin/admin_cubit.dart` + `admin_state.dart` ✅
- `ad/ad_cubit.dart` + `ad_state.dart` ✅
- `notification/notification_cubit.dart` + `notification_state.dart` ✅

### What was missing and has been added:

| Layer | Category | Count |
|-------|----------|-------|
| Domain | Enums | 5 new files |
| Domain | Entities | 4 new files |
| Domain | Business Rules | 2 new files |
| Domain | Services | 1 new file |
| Domain | Use Cases | 8 new files |
| Domain | Repository Interfaces | 1 modified |
| Core | API Endpoints | 1 modified |
| Data | Repository Impl | 1 modified |
| Data | Remote Datasource | 1 modified |
| Presentation | Cubits | 4 new files (2 cubits × state+cubit) |
| **Total** | | **22 new files + 4 modifications** |

---

*Document Version: 1.0*
*Generated: February 14, 2026*