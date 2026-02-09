# Baladi — Backend Developer Guide

## Complete API, Business Logic & Integration Reference

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Authentication & Authorization](#2-authentication--authorization)
3. [Domain Layer — Business Logic](#3-domain-layer--business-logic)
4. [Data Layer — Repositories, DTOs & Endpoints](#4-data-layer--repositories-dtos--endpoints)
5. [Order Lifecycle](#5-order-lifecycle)
6. [Points System](#6-points-system)
7. [Commission System](#7-commission-system)
8. [Weekly Settlements](#8-weekly-settlements)
9. [Example Requests & Responses](#9-example-requests--responses)
10. [Notifications](#10-notifications)
11. [Security & Edge Cases](#11-security--edge-cases)
12. [Database Schema Summary](#12-database-schema-summary)

---

## 1. Project Overview

### 1.1 What is Baladi?

Baladi is a daily-needs delivery application designed for small communities and villages. It connects local shops (restaurants, bakeries, pharmacies, cosmetics, daily essentials) with customers through delivery riders. The platform operates on a **cash-only** model and uses **Firebase Cloud Messaging** for push notifications.

### 1.2 User Roles

| Role | Description | Auth Method |
|------|-------------|-------------|
| **Customer** | Places orders, earns/redeems loyalty points, refers friends | Phone number + 4-digit PIN |
| **Shop** | Manages products, accepts/prepares orders, confirms cash receipt | Username + password |
| **Delivery Rider** | Picks up and delivers orders, collects/transfers cash | Username + password |
| **Admin** | Manages all users, closes weekly periods, approves settlements, adjusts points | Username + password |

### 1.3 Key Business Flows

```
Customer browses → Places order → Shop accepts → Shop prepares →
Rider picks up → Rider delivers (cash collected) → Rider pays shop →
Shop confirms cash → Order completed → Points awarded
```

### 1.4 Technology Expectations

| Component | Technology |
|-----------|------------|
| Database | PostgreSQL |
| API Framework | Node.js + Express (or equivalent REST API) |
| Authentication | JWT (access + refresh tokens) |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Hosting | VPS (~$5/month, e.g. DigitalOcean/Vultr) |

---

## 2. Authentication & Authorization

### 2.1 Customer Authentication

**Registration:** `POST /api/auth/customer/register`

```json
{
  "phone": "+201234567890",
  "pin": "1234",
  "full_name": "Ahmed Mohamed",
  "security_answer": "my mother's name"
}
```

- Phone number must be unique
- PIN is exactly 4 digits, stored as bcrypt hash (cost factor 12)
- Security answer stored as bcrypt hash (case-insensitive matching)
- Generate a unique referral code (e.g., `AHMED1234`)
- Return JWT access token (15 min expiry) + refresh token (7 days expiry)

**Login:** `POST /api/auth/customer/login`

```json
{
  "phone": "+201234567890",
  "pin": "1234"
}
```

- Rate limit: 5 failed attempts → 15-minute lockout
- Return JWT tokens on success

**PIN Recovery:** `POST /api/auth/customer/recover-pin`

```json
{
  "phone": "+201234567890",
  "security_answer": "my mother's name",
  "new_pin": "5678"
}
```

- Verify security answer (case-insensitive bcrypt compare)
- Rate limit recovery attempts

### 2.2 Staff Authentication (Shop, Rider, Admin)

**Login:** `POST /api/auth/login`

```json
{
  "username": "shop_alnour",
  "password": "SecurePass123"
}
```

- Password requirements: min 8 chars, at least one uppercase, one lowercase, one number
- Passwords stored as bcrypt hash (cost factor 12)
- Return JWT tokens with role claim

### 2.3 Token Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/refresh` | POST | Refresh expired access token using refresh token |
| `/api/auth/logout` | POST | Invalidate refresh token |
| `/api/auth/fcm-token` | PUT | Update FCM device token for push notifications |

**JWT Payload Structure:**

```json
{
  "sub": "user-uuid",
  "role": "customer",
  "iat": 1706000000,
  "exp": 1706000900
}
```

### 2.4 Role-Based Access Control (RBAC)

Every authenticated request must include `Authorization: Bearer <access_token>`.

| Endpoint Prefix | Allowed Roles |
|-----------------|---------------|
| `/api/customer/*` | `customer` |
| `/api/shop/*` | `shop` |
| `/api/rider/*` | `rider` |
| `/api/admin/*` | `admin` |
| `/api/categories`, `/api/shops/:id`, `/api/ads/active` | All authenticated |
| `/api/orders` (POST) | `customer` |
| `/api/orders` (GET) | All (filtered by role) |
| `/api/orders/:id/accept`, `/api/orders/:id/preparing` | `shop` |
| `/api/orders/:id/pickup`, `/api/orders/:id/deliver`, `/api/orders/:id/cash-to-shop` | `rider` |
| `/api/orders/:id/confirm-cash` | `shop` |
| `/api/orders/:id/cancel` | `customer`, `shop`, `admin` |

---

## 3. Domain Layer — Business Logic

### 3.1 Entities

| Entity | Key Fields |
|--------|------------|
| **User** | `id`, `role`, `phone`, `username`, `pin_hash`, `password_hash`, `security_answer_hash`, `fcm_token`, `is_active` |
| **Customer** | `id`, `user_id`, `full_name`, `address_text`, `landmark`, `area`, `total_points`, `referral_code`, `referred_by_id` |
| **Shop** | `id`, `user_id`, `name`, `name_ar`, `category_id`, `commission_rate` (default 10%), `is_open`, `min_order_amount` |
| **Rider** | `id`, `user_id`, `full_name`, `phone`, `delivery_fee` (default 10 EGP), `is_available` |
| **Product** | `id`, `shop_id`, `name`, `name_ar`, `price`, `is_available` |
| **Order** | `id`, `order_number`, `customer_id`, `shop_id`, `rider_id`, `status`, `subtotal`, `delivery_fee`, `points_used`, `points_discount`, `total_amount`, `shop_commission`, `admin_commission`, `points_earned`, `period_id` |
| **OrderItem** | `id`, `order_id`, `product_id`, `product_name`, `price`, `quantity`, `subtotal` |
| **WeeklyPeriod** | `id`, `year`, `week_number`, `start_date`, `end_date`, `status` |
| **ShopSettlement** | `id`, `shop_id`, `period_id`, `gross_sales`, `total_commission`, `points_discounts`, `net_amount` |
| **RiderSettlement** | `id`, `rider_id`, `period_id`, `total_deliveries`, `total_earnings`, `total_cash_handled` |
| **PointsTransaction** | `id`, `customer_id`, `order_id`, `type`, `points`, `balance_after` |

### 3.2 Business Rules

#### 3.2.1 Points Rules (`PointsRules`)

```
EARNING:
  formula:       points = floor(subtotal / 100)
  threshold:     Orders below 100 EGP earn 0 points
  no partials:   Only whole points, floor division only

EXAMPLES:
  0 EGP    → 0 points
  50 EGP   → 0 points
  99 EGP   → 0 points
  100 EGP  → 1 point
  150 EGP  → 1 point
  199 EGP  → 1 point
  200 EGP  → 2 points
  350 EGP  → 3 points
  1000 EGP → 10 points

REDEMPTION:
  1 point = 1 EGP discount on order total
  Maximum redeemable = min(available_points, floor(platform_commission))

REFERRAL BONUS:
  2 points awarded to referrer when referred customer completes first order

CONSTANTS:
  pointsPerCurrencyUnit = 100.0
  pointValueInCurrency  = 1.0
  referralBonusPoints   = 2
  minimumOrderForPoints = 100.0
```

#### 3.2.2 Commission Rules (`CommissionRules`)

```
PLATFORM COMMISSION (what the app collects from the store):
  store_commission = subtotal × store_commission_rate  (default 10%)

ADMIN/APP NET COMMISSION:
  admin_commission = store_commission - points_discount - free_delivery_cost
  Minimum: 0 (cannot go negative)

STORE EARNINGS:
  store_receives = subtotal - store_commission
  NOTE: Store NEVER loses money from points — see settlement logic

RIDER EARNINGS:
  rider_receives = delivery_fee  (fixed, default 10 EGP)
  NOTE: Rider NEVER loses money from points

CUSTOMER PAYS:
  customer_pays = subtotal + delivery_fee - points_discount
```

#### 3.2.3 Personal Commission Rules (`PersonalCommissionService`)

This is a **separate tracking layer** for the app owner's personal commission. It does NOT affect store, rider, or platform calculations — it is tracked independently for internal accounting.

```
FROM STORE:
  personal_from_store = subtotal × 0.05  (5% of order subtotal)

FROM DELIVERY:
  personal_from_delivery = delivery_fee × 0.15  (15% of delivery fee)
  Default: 10 × 0.15 = 1.5 EGP per order

TOTAL PERSONAL COMMISSION PER ORDER:
  total = personal_from_store + personal_from_delivery

INDEPENDENCE:
  - Does NOT reduce store earnings
  - Does NOT reduce rider earnings
  - Does NOT reduce platform commission
  - Tracked separately for personal accounting only

EDGE CASES:
  - Negative or zero subtotal → personal_from_store = 0
  - Free delivery → personal_from_delivery = 0
  - Decimal subtotals → round to 2 decimal places
```

#### 3.2.4 Order Rules

```
VALIDATION:
  - At least 1 item per order
  - Subtotal must meet shop's min_order_amount
  - Shop must be open and active
  - Delivery address is required

CANCELLATION:
  - Allowed in: pending, accepted statuses only
  - Customer, shop, or admin can cancel
  - Cancellation reason required
  - No points earned on cancelled orders
  - If points were redeemed, refund them back to customer
```

### 3.3 Services

#### 3.3.1 PointsService

| Method | Signature | Description |
|--------|-----------|-------------|
| `calculateEarnedPoints` | `(double subtotal) → int` | Returns `floor(subtotal / 100)`, 0 if subtotal < 100 or negative |
| `applyPoints` | `(orderTotal, pointsToUse, availablePoints, [maxRedeemablePoints]) → PointsApplyResult` | Caps pointsToUse at min(requested, available, maxRedeemable, orderTotal); returns discount, new total, store weekly credit |
| `validatePointsRedemption` | `(pointsToUse, availablePoints, platformCommission) → PointsValidationResult` | Validates: positive, ≤ available, discount ≤ commission |
| `getMaxRedeemablePoints` | `(platformCommission, availablePoints) → int` | Returns `min(availablePoints, floor(platformCommission))` |
| `recordPointsUsage` | `(orderId, storeId, pointsUsed, monetaryValue) → PointsUsageRecord` | Creates a timestamped record for settlement tracking |
| `calculateStoreWeeklyPointsCredit` | `(records[], storeId) → double` | Sums monetary value of all points used at a specific store during a period |

**PointsApplyResult:**

```
{
  pointsUsed: int,
  discountAmount: double,        // pointsUsed × 1.0
  originalTotal: double,
  newTotal: double,              // originalTotal - discountAmount
  storeWeeklyCommissionCredit: double,  // == discountAmount (app pays this to store)
  hasDiscount: bool
}
```

**PointsValidationResult:**

```
{
  isValid: bool,
  errorMessage: string?,
  discountValue: double?
}
```

**PointsUsageRecord:**

```
{
  orderId: string,
  storeId: string,
  pointsUsed: int,
  monetaryValue: double,
  usedAt: DateTime
}
```

#### 3.3.2 PersonalCommissionService

| Method | Signature | Description |
|--------|-----------|-------------|
| `commissionFromStore` | `(double subtotal) → double` | Returns `subtotal × 0.05`, 0 if negative |
| `commissionFromDelivery` | `([double fee = 10.0]) → double` | Returns `fee × 0.15`, 0 if negative |
| `calculateTotalCommission` | `(subtotal, [deliveryFee, isFreeDelivery]) → TotalCommissionResult` | Combined personal commission |

**TotalCommissionResult:**

```
{
  fromStore: double,
  fromDelivery: double,
  total: double,
  orderSubtotal: double,
  deliveryFee: double
}
```

---

## 4. Data Layer — Repositories, DTOs & Endpoints

### 4.1 API Endpoints — Complete Reference

#### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/auth/customer/register` | Register customer with phone + PIN | No |
| POST | `/api/auth/customer/login` | Login with phone + PIN | No |
| POST | `/api/auth/customer/recover-pin` | Recover PIN via security question | No |
| POST | `/api/auth/login` | Login for shop/rider/admin | No |
| POST | `/api/auth/refresh` | Refresh JWT token | Yes |
| POST | `/api/auth/logout` | Logout | Yes |
| PUT | `/api/auth/fcm-token` | Update FCM token | Yes |

#### Customer

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/customer/profile` | Get customer profile |
| PUT | `/api/customer/profile` | Update profile |
| PUT | `/api/customer/address` | Update delivery address |
| GET | `/api/customer/points` | Get points balance |
| GET | `/api/customer/points/history` | Get points transaction history |
| GET | `/api/customer/referral` | Get referral code and stats |
| POST | `/api/customer/referral/apply` | Apply referral code |

#### Catalog

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | List all active categories |
| GET | `/api/categories/:slug/shops` | List shops in category |
| GET | `/api/shops/:id` | Get shop details |
| GET | `/api/shops/:id/products` | Get shop products |

#### Orders

| Method | Endpoint | Description | Roles |
|--------|----------|-------------|-------|
| POST | `/api/orders` | Create order | Customer |
| GET | `/api/orders` | List my orders (filtered by role) | All |
| GET | `/api/orders/:id` | Get order details | All |
| POST | `/api/orders/:id/accept` | Accept order | Shop |
| POST | `/api/orders/:id/preparing` | Start preparing | Shop |
| POST | `/api/orders/:id/assign-rider` | Assign rider | Shop/Admin |
| POST | `/api/orders/:id/pickup` | Mark picked up | Rider |
| POST | `/api/orders/:id/deliver` | Mark delivered | Rider |
| POST | `/api/orders/:id/cash-to-shop` | Cash handed to shop | Rider |
| POST | `/api/orders/:id/confirm-cash` | Confirm cash received | Shop |
| POST | `/api/orders/:id/cancel` | Cancel order | Customer/Shop/Admin |

#### Shop Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/shop/profile` | Get shop profile |
| PUT | `/api/shop/profile` | Update shop profile |
| PUT | `/api/shop/status` | Toggle open/closed |
| GET | `/api/shop/products` | List products |
| POST | `/api/shop/products` | Add product |
| PUT | `/api/shop/products/:id` | Update product |
| DELETE | `/api/shop/products/:id` | Delete product |
| GET | `/api/shop/orders` | List shop orders |
| GET | `/api/shop/dashboard` | Get dashboard stats |
| GET | `/api/shop/settlements` | List settlements |

#### Rider

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/rider/profile` | Get profile |
| PUT | `/api/rider/status` | Toggle availability |
| GET | `/api/rider/orders/available` | List available orders |
| GET | `/api/rider/orders` | List my orders |
| GET | `/api/rider/dashboard` | Get dashboard stats |
| GET | `/api/rider/earnings` | Get earnings |
| GET | `/api/rider/settlements` | List settlements |

#### Ads

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/ads/active` | List active ads |
| POST | `/api/shop/ads` | Create ad |
| GET | `/api/shop/ads` | List shop's ads |
| PUT | `/api/shop/ads/:id` | Update ad |
| DELETE | `/api/shop/ads/:id` | Delete ad |

#### Admin

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/dashboard` | Get admin dashboard |
| GET | `/api/admin/users` | List all users |
| PUT | `/api/admin/users/:id/activate` | Activate/deactivate user |
| POST | `/api/admin/users/:id/reset-password` | Reset password |
| GET | `/api/admin/shops` | List all shops |
| POST | `/api/admin/shops` | Create shop (with user account) |
| PUT | `/api/admin/shops/:id` | Update shop |
| GET | `/api/admin/riders` | List all riders |
| POST | `/api/admin/riders` | Create rider (with user account) |
| PUT | `/api/admin/riders/:id` | Update rider |
| GET | `/api/admin/orders` | List all orders |
| GET | `/api/admin/periods` | List weekly periods |
| POST | `/api/admin/periods/close` | Close current week and generate settlements |
| GET | `/api/admin/settlements` | List all settlements |
| POST | `/api/admin/settlements/:id/settle` | Mark settlement as paid |
| POST | `/api/admin/points/adjust` | Manually adjust customer points |

### 4.2 Standard API Response Format

**Success:**

```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 145
  }
}
```

**Error:**

```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_POINTS",
    "message": "You don't have enough points. Available: 5, Requested: 20",
    "details": {}
  }
}
```

### 4.3 Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or expired token |
| `FORBIDDEN` | 403 | Role not permitted for this action |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 422 | Invalid request body |
| `INSUFFICIENT_POINTS` | 400 | Not enough points to redeem |
| `SHOP_CLOSED` | 400 | Shop is not currently open |
| `MIN_ORDER_NOT_MET` | 400 | Subtotal below shop's minimum |
| `INVALID_STATUS_TRANSITION` | 400 | Order cannot move to requested status |
| `DUPLICATE_REFERRAL` | 400 | Referral code already applied |
| `RATE_LIMITED` | 429 | Too many requests |

---

## 5. Order Lifecycle

### 5.1 Status Flow

```
                    ┌─────────┐
                    │ PENDING │ ◄── Customer places order
                    └────┬────┘
                         │ Shop accepts
                    ┌────▼─────┐
           ┌───────│ ACCEPTED │
           │        └────┬─────┘
           │             │ Shop starts preparing
           │        ┌────▼──────┐
           │        │ PREPARING │
           │        └────┬──────┘
           │             │ Rider picks up
           │        ┌────▼──────┐
           │        │ PICKED_UP │
           │        └────┬──────┘
           │             │ Rider delivers + hands cash to shop
           │        ┌────▼──────┐
           │        │ SHOP_PAID │
           │        └────┬──────┘
           │             │ Shop confirms cash
           │        ┌────▼──────┐
           │        │ COMPLETED │ ──► Points awarded to customer
           │        └───────────┘
           │
           │        ┌───────────┐
           └───────►│ CANCELLED │ ◄── From: pending or accepted only
                    └───────────┘
```

### 5.2 Valid Status Transitions

| From | To | Who Can Trigger |
|------|----|-----------------|
| `pending` | `accepted` | Shop |
| `pending` | `cancelled` | Customer, Shop, Admin |
| `accepted` | `preparing` | Shop |
| `accepted` | `cancelled` | Shop, Admin |
| `preparing` | `picked_up` | Rider |
| `picked_up` | `shop_paid` | Rider (confirms cash to shop) |
| `shop_paid` | `completed` | Shop (confirms cash received) |

**Invalid transitions must return `INVALID_STATUS_TRANSITION` error.**

### 5.3 Order Creation Logic

When a customer creates an order via `POST /api/orders`, the backend must:

1. **Validate** the shop is open and active
2. **Validate** all products exist, are available, and belong to the shop
3. **Calculate subtotal** = sum of (product_price × quantity) for all items
4. **Validate** subtotal ≥ shop's `min_order_amount`
5. **Determine delivery fee** (default 10 EGP; 0 if free delivery promotion)
6. **If points are being used:**
   a. Fetch customer's `total_points`
   b. Calculate `store_commission = subtotal × shop.commission_rate`
   c. Calculate `max_redeemable = min(customer.total_points, floor(store_commission))`
   d. Cap `points_to_use` at `max_redeemable`
   e. Calculate `points_discount = points_to_use × 1.0`
7. **Calculate commissions:**
   - `shop_commission = subtotal × shop.commission_rate`
   - `admin_commission = shop_commission - points_discount - free_delivery_cost`
   - Ensure `admin_commission >= 0`
8. **Calculate total:** `total_amount = subtotal + delivery_fee - points_discount`
9. **Calculate points earned:** `points_earned = floor(subtotal / 100)`
10. **Generate order number** (e.g., `ORD-2026-00123`)
11. **Assign to current active weekly period**
12. **Create order record** + order items
13. **Deduct used points** from customer's `total_points` and create points_transaction record
14. **Send push notification** to shop

### 5.4 Order Completion Logic

When an order transitions to `completed`:

1. **Award earned points** to customer:
   - Add `points_earned` to customer's `total_points`
   - Create points_transaction record with type `earned`
2. **Check referral bonus:**
   - If this is the customer's first completed order AND they were referred
   - Award 2 points to the referrer
   - Mark referral as completed
3. **Record points usage** for settlement (if points were used):
   - Create a points usage record linking the order, store, points used, and monetary value
4. **Send push notification** to customer with points earned

### 5.5 Order Cancellation Logic

When an order is cancelled:

1. **Validate** order is in `pending` or `accepted` status
2. **If points were used:** refund `points_used` back to customer's `total_points`, create points_transaction with type `adjustment`
3. **Do NOT award** any `points_earned`
4. **Record cancellation reason**
5. **Send push notification** to affected parties

---

## 6. Points System

### 6.1 Points Earning

```
Formula: points = floor(subtotal / 100)

Truth Table:
┌──────────────────┬────────────────┐
│ Order Subtotal   │ Points Earned  │
├──────────────────┼────────────────┤
│ 0 EGP            │ 0              │
│ 50 EGP           │ 0              │
│ 99 EGP           │ 0              │
│ 100 EGP          │ 1              │
│ 150 EGP          │ 1              │
│ 199 EGP          │ 1              │
│ 200 EGP          │ 2              │
│ 250 EGP          │ 2              │
│ 299 EGP          │ 2              │
│ 300 EGP          │ 3              │
│ 350 EGP          │ 3              │
│ 500 EGP          │ 5              │
│ 1000 EGP         │ 10             │
└──────────────────┴────────────────┘

Points are awarded ONLY when order status reaches "completed".
Points are calculated from the original subtotal (before any discount).
```

### 6.2 Points Redemption

```
1 point = 1 EGP discount

Maximum redeemable per order:
  max = min(customer.total_points, floor(platform_commission))

Where:
  platform_commission = subtotal × store_commission_rate

This ensures the app's commission can cover the discount cost.
```

### 6.3 Critical Accounting Rule: Who Bears the Cost?

```
┌─────────────────────────────────────────────────────────────────┐
│                    POINTS COST ALLOCATION                       │
│                                                                 │
│  THE APP (PLATFORM) BEARS 100% OF THE POINTS DISCOUNT COST    │
│                                                                 │
│  • Store receives full earnings (subtotal - store_commission)  │
│    PLUS points_discount value credited in weekly settlement    │
│                                                                 │
│  • Rider receives full delivery fee, unmodified                │
│                                                                 │
│  • App commission = store_commission - points_discount          │
│    (reduced by the discount amount)                            │
└─────────────────────────────────────────────────────────────────┘
```

**Worked Example:**

```
Order subtotal:        300 EGP
Delivery fee:          10 EGP
Points used:           10 points (= 10 EGP discount)
Store commission rate:  10%

Calculations:
  store_commission   = 300 × 0.10 = 30 EGP
  admin_commission   = 30 - 10 = 20 EGP  ← App gets less
  points_discount    = 10 EGP
  customer_pays      = 300 + 10 - 10 = 300 EGP
  store_receives     = 300 - 30 = 270 EGP  ← UNCHANGED
  rider_receives     = 10 EGP              ← UNCHANGED
  points_earned      = floor(300 / 100) = 3 points

Settlement adjustment:
  store_weekly_credit = +10 EGP  (added to store's weekly settlement)
  app_commission_reduction = -10 EGP (deducted from app's weekly commission)

Result: Store gets 270 + 10 = 280 EGP effective (same as if no points were used
        and the customer paid full 310 EGP, where store would get 300 - 30 = 270,
        but the 10 EGP points credit compensates).
```

### 6.4 Points Transaction Types

| Type | Description | Points Direction |
|------|-------------|------------------|
| `earned` | Points earned from completed order | + (positive) |
| `redeemed` | Points used for order discount | - (negative) |
| `referral` | Bonus from referred user's first order | + (positive) |
| `adjustment` | Admin manual adjustment or refund | +/- (either) |

### 6.5 Points Database Operations

**On order creation (if points used):**

```sql
-- Deduct points from customer
UPDATE customers 
SET total_points = total_points - :points_used,
    updated_at = NOW()
WHERE id = :customer_id 
  AND total_points >= :points_used;

-- Record points transaction
INSERT INTO points_transactions (customer_id, order_id, type, points, balance_after, description)
VALUES (:customer_id, :order_id, 'redeemed', -:points_used, 
        (SELECT total_points FROM customers WHERE id = :customer_id),
        'Points redeemed for order #' || :order_number);
```

**On order completion (award earned points):**

```sql
-- Add earned points
UPDATE customers 
SET total_points = total_points + :points_earned,
    updated_at = NOW()
WHERE id = :customer_id;

-- Record points transaction
INSERT INTO points_transactions (customer_id, order_id, type, points, balance_after, description)
VALUES (:customer_id, :order_id, 'earned', :points_earned,
        (SELECT total_points FROM customers WHERE id = :customer_id),
        'Earned from order #' || :order_number);
```

**On order cancellation (refund redeemed points):**

```sql
-- Refund points if they were used
UPDATE customers 
SET total_points = total_points + :points_used,
    updated_at = NOW()
WHERE id = :customer_id AND :points_used > 0;

-- Record refund transaction
INSERT INTO points_transactions (customer_id, order_id, type, points, balance_after, description)
VALUES (:customer_id, :order_id, 'adjustment', :points_used,
        (SELECT total_points FROM customers WHERE id = :customer_id),
        'Points refunded for cancelled order #' || :order_number);
```

---

## 7. Commission System

### 7.1 Platform Commission (Store → App)

```
store_commission_amount = subtotal × store.commission_rate

Default commission_rate = 10% (configurable per shop by admin)

This is the amount the store owes the platform.
Store's net earnings = subtotal - store_commission_amount
```

### 7.2 Admin/App Net Commission

```
admin_commission = store_commission_amount - points_discount - free_delivery_cost

If admin_commission < 0, set to 0 (app absorbs the loss)

free_delivery_cost = delivery_fee (if order has free delivery, else 0)
```

### 7.3 Personal Commission (Tracked Separately)

```
personal_from_store    = subtotal × 0.05  (5%)
personal_from_delivery = delivery_fee × 0.15  (15%)
personal_total         = personal_from_store + personal_from_delivery

IMPORTANT: This is tracked for internal accounting only.
It does NOT reduce store earnings, rider earnings, or platform commission.
It does NOT appear in settlements.
It is NOT deducted from any party.

For orders with free delivery:
  personal_from_delivery = 0

For negative/zero subtotals:
  personal_from_store = 0

Rounding: Round to 2 decimal places
```

### 7.4 Commission Flow per Order

```
                    Customer pays: subtotal + delivery_fee - points_discount
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────────────┐
        │   Store   │   │  Rider   │   │  App (Platform)  │
        │          │   │          │   │                  │
        │ subtotal  │   │ delivery │   │ store_commission │
        │ - store   │   │ fee      │   │ - points_discount│
        │ commission│   │ (full)   │   │ - free_delivery  │
        │ + points  │   │          │   │ = admin_commission│
        │   credit  │   │          │   │                  │
        │ (in       │   │          │   │ Personal tracking:│
        │ settlement)│   │          │   │ 5% store + 15%   │
        │          │   │          │   │ delivery (separate)│
        └──────────┘   └──────────┘   └──────────────────┘
```

---

## 8. Weekly Settlements

### 8.1 Week Period Definition

```
Week Start: Saturday 00:00:00 (Cairo Time, UTC+2)
Week End:   Friday 23:59:59 (Cairo Time, UTC+2)

Period identification: year + week_number (e.g., 2026-W03)
```

### 8.2 Settlement Generation Process

When admin calls `POST /api/admin/periods/close`:

#### Step 1: Validate

- Ensure there's an active period
- Ensure no orders in `pending` or `accepted` status in this period (warn admin)

#### Step 2: Calculate Shop Settlements

For each shop with completed orders in the period:

```sql
SELECT 
  shop_id,
  COUNT(*) as total_orders,
  COUNT(*) FILTER (WHERE status = 'completed') as completed_orders,
  COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_orders,
  SUM(subtotal) FILTER (WHERE status = 'completed') as gross_sales,
  SUM(shop_commission) FILTER (WHERE status = 'completed') as total_commission,
  SUM(points_discount) FILTER (WHERE status = 'completed') as points_discounts,
  SUM(CASE WHEN is_free_delivery THEN delivery_fee ELSE 0 END) 
    FILTER (WHERE status = 'completed') as free_delivery_cost
FROM orders
WHERE period_id = :period_id
GROUP BY shop_id;
```

**Shop settlement net amount calculation:**

```
gross_sales          = sum of subtotals for completed orders
total_commission     = sum of shop_commission for completed orders
points_discounts     = sum of points_discount for completed orders (CREDITED TO STORE)
ads_cost             = sum of ad costs for this shop in this period
free_delivery_cost   = sum of delivery fees absorbed for free delivery orders

net_amount = gross_sales - total_commission + points_discounts - ads_cost

Explanation:
  - Store earns gross_sales
  - Store pays total_commission to platform
  - Store gets points_discounts BACK (platform pays this)
  - Store pays ads_cost
```

**CRITICAL:** The `points_discounts` is ADDED to the store's net, not subtracted. This is because the app bears the cost of points, so the store is credited with the discount value.

#### Step 3: Calculate Rider Settlements

For each rider with completed deliveries in the period:

```sql
SELECT
  rider_id,
  COUNT(*) as total_deliveries,
  SUM(delivery_fee) as total_earnings,
  SUM(total_amount) as total_cash_handled
FROM orders
WHERE period_id = :period_id
  AND status = 'completed'
  AND rider_id IS NOT NULL
GROUP BY rider_id;
```

Rider settlement:

```
total_earnings = sum of delivery_fee for completed orders
total_cash_handled = sum of total_amount (cash rider collected from customers)

NOTE: Rider earnings are NEVER affected by points discounts.
The delivery_fee column is always the full fee.
```

#### Step 4: Calculate Admin Summary

```
admin_total_commissions = SUM(shop_commission) for all completed orders
admin_points_cost       = SUM(points_discount) for all completed orders  ← APP PAYS THIS
admin_free_delivery_cost = SUM(free_delivery_cost) for all completed orders
admin_ads_revenue       = SUM(ads_cost) for all shops in period
admin_net_revenue       = admin_total_commissions - admin_points_cost 
                          - admin_free_delivery_cost + admin_ads_revenue
```

#### Step 5: Finalize

1. Create `shop_settlements` records
2. Create `rider_settlements` records
3. Mark period as `closed`
4. Create new period for next week
5. Send push notifications to all shops and riders

### 8.3 Settlement Report Structure

```json
{
  "period": {
    "id": "uuid",
    "year": 2026,
    "week_number": 3,
    "start_date": "2026-01-17",
    "end_date": "2026-01-23",
    "status": "closed"
  },
  "admin_summary": {
    "total_orders": 145,
    "completed_orders": 138,
    "cancelled_orders": 7,
    "gross_sales": 24500.00,
    "total_delivery_fees": 1380.00,
    "total_shop_commissions": 2450.00,
    "total_points_redeemed_value": 180.00,
    "total_free_delivery_cost": 120.00,
    "total_ads_revenue": 280.00,
    "admin_net_revenue": 2430.00,
    "personal_commission_store": 1225.00,
    "personal_commission_delivery": 207.00,
    "personal_commission_total": 1432.00
  },
  "shop_settlements": [
    {
      "id": "settlement-uuid",
      "shop_id": "shop-uuid",
      "shop_name": "Fresh Bakery",
      "total_orders": 42,
      "completed_orders": 40,
      "cancelled_orders": 2,
      "gross_sales": 7800.00,
      "total_commission": 780.00,
      "points_discounts_credited": 45.00,
      "ads_cost": 70.00,
      "net_amount": 6995.00,
      "status": "pending"
    }
  ],
  "rider_settlements": [
    {
      "id": "settlement-uuid",
      "rider_id": "rider-uuid",
      "rider_name": "Mohamed",
      "total_deliveries": 35,
      "total_earnings": 350.00,
      "total_cash_handled": 8200.00,
      "status": "pending"
    }
  ]
}
```

### 8.4 Settlement Net Amount Formula (Shop)

```
net_amount = gross_sales
           - total_commission        (what store owes the platform)
           + points_discounts        (what platform owes the store for points used)
           - ads_cost                (what store owes for ads)

Example:
  gross_sales      = 7800
  total_commission = 780   (10% of 7800)
  points_discounts = 45    (total points discount value from orders at this shop)
  ads_cost         = 70

  net_amount = 7800 - 780 + 45 - 70 = 6995 EGP

Without points, it would be: 7800 - 780 - 70 = 6950 EGP
The store gets 45 EGP MORE because of points credits.
The app absorbs this 45 EGP cost from its commission.
```

---

## 9. Example Requests & Responses

### 9.1 Create Order

**Request:** `POST /api/orders`

```json
{
  "shop_id": "shop-uuid-123",
  "items": [
    {
      "product_id": "prod-uuid-1",
      "quantity": 2,
      "notes": "Extra sauce"
    },
    {
      "product_id": "prod-uuid-2",
      "quantity": 1
    }
  ],
  "delivery_address": "123 El-Tahrir St, Apt 4B",
  "delivery_landmark": "Near the mosque",
  "delivery_area": "Downtown",
  "points_to_use": 5,
  "customer_notes": "Please ring the bell twice"
}
```

**Response:** `201 Created`

```json
{
  "success": true,
  "data": {
    "order": {
      "id": "order-uuid-456",
      "order_number": "ORD-2026-00123",
      "status": "pending",
      "shop": {
        "id": "shop-uuid-123",
        "name": "Al-Nour Restaurant"
      },
      "items": [
        {
          "product_name": "Grilled Chicken",
          "price": 120.00,
          "quantity": 2,
          "subtotal": 240.00
        },
        {
          "product_name": "Rice",
          "price": 60.00,
          "quantity": 1,
          "subtotal": 60.00
        }
      ],
      "financials": {
        "subtotal": 300.00,
        "delivery_fee": 10.00,
        "points_used": 5,
        "points_discount": 5.00,
        "total_amount": 305.00,
        "points_earned": 3
      },
      "delivery_address": "123 El-Tahrir St, Apt 4B",
      "delivery_landmark": "Near the mosque",
      "created_at": "2026-01-19T14:30:00Z"
    }
  }
}
```

### 9.2 Commission Calculation Example

For the order above:

```
Input:
  subtotal = 300 EGP
  delivery_fee = 10 EGP
  points_used = 5 (= 5 EGP discount)
  store_commission_rate = 10%
  is_free_delivery = false

Platform Commission:
  store_commission = 300 × 0.10 = 30 EGP
  admin_commission = 30 - 5 - 0 = 25 EGP

Personal Commission (tracked separately):
  from_store = 300 × 0.05 = 15 EGP
  from_delivery = 10 × 0.15 = 1.5 EGP
  total_personal = 16.5 EGP

Financial Distribution:
  customer_pays = 300 + 10 - 5 = 305 EGP
  store_receives = 300 - 30 = 270 EGP (+ 5 EGP credit in settlement)
  rider_receives = 10 EGP
  app_receives = 25 EGP (reduced from 30 by 5 EGP points cost)
```

### 9.3 Points Usage Effect on Weekly Settlement

**Scenario:** During Week 3, Shop "Fresh Bakery" had these orders with points usage:

| Order | Subtotal | Points Used | Points Discount |
|-------|----------|-------------|-----------------|
| #101 | 200 EGP | 10 | 10 EGP |
| #102 | 300 EGP | 0 | 0 EGP |
| #103 | 150 EGP | 5 | 5 EGP |
| #104 | 350 EGP | 20 | 20 EGP |
| **Total** | **1000 EGP** | **35** | **35 EGP** |

**Settlement Calculation:**

```
gross_sales      = 1000 EGP
total_commission = 1000 × 0.10 = 100 EGP  (store owes platform)
points_discounts = 35 EGP                  (platform owes store)
ads_cost         = 0 EGP

net_amount = 1000 - 100 + 35 - 0 = 935 EGP  (store receives)

Without points: 1000 - 100 = 900 EGP
With points:    1000 - 100 + 35 = 935 EGP

App commission: 100 - 35 = 65 EGP  (reduced from 100 by points cost)
```

### 9.4 Points Earning Examples

**Request:** `POST /api/orders` with various subtotals

| Subtotal | Points Earned | Explanation |
|----------|---------------|-------------|
| 50 EGP | 0 | floor(50/100) = 0 |
| 99 EGP | 0 | floor(99/100) = 0 |
| 100 EGP | 1 | floor(100/100) = 1 |
| 250 EGP | 2 | floor(250/100) = 2 |
| 999 EGP | 9 | floor(999/100) = 9 |

---

## 10. Notifications

### 10.1 Push Notification Events

| Event | Recipients | Title | Body Template |
|-------|------------|-------|---------------|
| Order placed | Shop | "New Order! 🛒" | "New order #{order_number} — {item_count} items, {total} EGP" |
| Order accepted | Customer | "Order Accepted ✅" | "{shop_name} accepted your order" |
| Order preparing | Customer | "Preparing Your Order 👨‍🍳" | "{shop_name} is preparing your order" |
| Rider assigned | Customer, Shop | "Rider On The Way 🛵" | "{rider_name} is heading to pick up your order" |
| Order picked up | Customer | "Order Picked Up 📦" | "Your order is on its way!" |
| Order delivered | Customer | "Order Delivered! 🎊" | "Enjoy! You earned {points} points" |
| Order cancelled | Affected parties | "Order Cancelled ❌" | "Order #{order_number} has been cancelled" |
| Settlement ready | Shop, Rider | "Weekly Summary 📊" | "Your Week {week_number} settlement is ready" |
| Points earned | Customer | "Points Earned! 💎" | "You earned {points} points. Balance: {balance}" |
| Referral bonus | Referrer | "Referral Bonus! 🎁" | "{name} placed their first order! +2 points" |

### 10.2 Notification Implementation

```javascript
// Example: Send FCM notification
async function sendNotification(userId, title, body, data = {}) {
  const user = await db.users.findById(userId);
  if (!user?.fcm_token) return;

  await admin.messaging().send({
    token: user.fcm_token,
    notification: { title, body },
    data: {
      type: data.type || 'general',
      order_id: data.orderId || '',
      ...data
    },
    android: {
      priority: 'high',
      notification: { sound: 'default' }
    },
    apns: {
      payload: {
        aps: { sound: 'default', badge: 1 }
      }
    }
  });

  // Also save to notifications table for in-app notification center
  await db.notifications.create({
    user_id: userId,
    title,
    body,
    type: data.type || 'general',
    data: data,
    is_read: false
  });
}
```

---

## 11. Security & Edge Cases

### 11.1 Security Requirements

| Requirement | Implementation |
|-------------|----------------|
| Password hashing | bcrypt with cost factor 12 |
| PIN hashing | bcrypt with cost factor 12 |
| JWT signing | HS256 with strong secret (min 64 chars) |
| Access token expiry | 15 minutes |
| Refresh token expiry | 7 days |
| Rate limiting (auth) | 5 failed attempts → 15-min lockout |
| Rate limiting (API) | 100 req/min per user, 1000 req/min per IP |
| Input sanitization | Parameterized queries (prevent SQL injection) |
| HTTPS | Required for all endpoints |

### 11.2 Edge Cases to Handle

| Scenario | Expected Behavior |
|----------|-------------------|
| **Subtotal = 0** | 0 points earned, no commission |
| **Negative subtotal** | Reject order (validation error) |
| **Points used > available** | Cap at available points |
| **Points discount > platform commission** | Cap at floor(platform_commission) |
| **Free delivery order** | delivery_fee = 0, no delivery commission, free_delivery_cost tracked |
| **Shop closed** | Reject order with `SHOP_CLOSED` error |
| **Cancelled order with points** | Refund all used points back to customer |
| **Duplicate referral code** | Reject with `DUPLICATE_REFERRAL` error |
| **Referral to self** | Reject |
| **Concurrent points deduction** | Use database-level atomic update with WHERE clause checking balance |
| **Order in mid-flow during week close** | Warn admin; do not include unfinished orders in settlement |
| **Shop with 0 completed orders** | Do not create settlement record (or create with 0 amounts) |
| **Decimal rounding** | Always round monetary values to 2 decimal places |
| **Very large order** | No upper limit, but validate all products exist |

### 11.3 Atomic Points Operation

Points deduction must be atomic to prevent race conditions:

```sql
-- Atomic deduction with balance check
UPDATE customers 
SET total_points = total_points - :points_to_use,
    updated_at = NOW()
WHERE id = :customer_id 
  AND total_points >= :points_to_use
RETURNING total_points;

-- If no rows returned, insufficient balance
```

### 11.4 Idempotency

- Order status transitions should be idempotent (transitioning to current status = no-op)
- Points awards should check if already awarded for this order (prevent double-awarding)
- Settlement generation should check if settlement already exists for shop+period

---

## 12. Database Schema Summary

### 12.1 Tables

| Table | Purpose | Key Constraints |
|-------|---------|-----------------|
| `users` | All user accounts | `UNIQUE(phone)`, `UNIQUE(username)` |
| `customers` | Customer profiles | `UNIQUE(user_id)`, `UNIQUE(referral_code)` |
| `categories` | Shop categories | `UNIQUE(slug)` |
| `shops` | Shop profiles | `UNIQUE(user_id)` |
| `riders` | Rider profiles | `UNIQUE(user_id)` |
| `products` | Shop products | FK to `shops` |
| `weekly_periods` | Week definitions | `UNIQUE(year, week_number)` |
| `orders` | Order records | FK to customers, shops, riders, periods |
| `order_items` | Order line items | FK to `orders`, `products` |
| `order_status_history` | Status change audit trail | FK to `orders` |
| `points_transactions` | Points earning/redemption log | FK to `customers`, `orders` |
| `referrals` | Referral tracking | FK to `customers` |
| `shop_settlements` | Weekly shop settlements | `UNIQUE(shop_id, period_id)` |
| `rider_settlements` | Weekly rider settlements | `UNIQUE(rider_id, period_id)` |
| `ads` | Shop advertisements | FK to `shops` |
| `notifications` | In-app notifications | FK to `users` |
| `audit_logs` | System audit trail | FK to `users` |

### 12.2 Key Indexes

```sql
-- Performance-critical indexes
CREATE INDEX idx_orders_customer_date ON orders(customer_id, created_at DESC);
CREATE INDEX idx_orders_shop_date ON orders(shop_id, created_at DESC);
CREATE INDEX idx_orders_rider_date ON orders(rider_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_period ON orders(period_id);
CREATE INDEX idx_points_customer_date ON points_transactions(customer_id, created_at DESC);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
```

### 12.3 Order Table Financial Columns

```sql
-- These columns must be populated on order creation
subtotal DECIMAL(10,2) NOT NULL,          -- Sum of all item prices × quantities
delivery_fee DECIMAL(10,2) DEFAULT 0,     -- Delivery fee (0 if free)
is_free_delivery BOOLEAN DEFAULT false,   -- Whether delivery is free (promotional)
points_used INTEGER DEFAULT 0,            -- Number of points customer used
points_discount DECIMAL(10,2) DEFAULT 0,  -- Monetary value of points used (= points_used × 1.0)
total_amount DECIMAL(10,2) NOT NULL,      -- What customer actually pays

shop_commission DECIMAL(10,2) DEFAULT 0,  -- subtotal × store commission rate
admin_commission DECIMAL(10,2) DEFAULT 0, -- shop_commission - points_discount - free_delivery_cost

points_earned INTEGER DEFAULT 0,          -- floor(subtotal / 100), awarded on completion
```

---

## Appendix A: Quick Reference Formulas

```
┌─────────────────────────────────────────────────────────────────┐
│                    FORMULA QUICK REFERENCE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POINTS EARNED:                                                 │
│    points = floor(subtotal / 100)                               │
│                                                                 │
│  POINTS VALUE:                                                  │
│    1 point = 1 EGP                                              │
│                                                                 │
│  MAX REDEEMABLE:                                                │
│    max = min(available_points, floor(store_commission))          │
│                                                                 │
│  STORE COMMISSION:                                              │
│    shop_commission = subtotal × commission_rate                  │
│                                                                 │
│  APP COMMISSION:                                                │
│    admin_commission = shop_commission - points_discount          │
│                       - free_delivery_cost                       │
│    minimum: 0                                                   │
│                                                                 │
│  CUSTOMER PAYS:                                                 │
│    total = subtotal + delivery_fee - points_discount             │
│                                                                 │
│  STORE RECEIVES (per order):                                    │
│    store_net = subtotal - shop_commission                        │
│                                                                 │
│  STORE SETTLEMENT (weekly):                                     │
│    net = gross_sales - total_commission + points_credits         │
│          - ads_cost                                             │
│                                                                 │
│  RIDER RECEIVES:                                                │
│    rider_earnings = delivery_fee (always full, unaffected)       │
│                                                                 │
│  PERSONAL COMMISSION (tracked separately):                      │
│    from_store = subtotal × 0.05                                 │
│    from_delivery = delivery_fee × 0.15                          │
│                                                                 │
│  REFERRAL BONUS: 2 points to referrer                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Appendix B: Order Financial Scenarios

### Scenario 1: Normal Order, No Points

```
Subtotal: 200 EGP | Delivery: 10 EGP | Points: 0

Customer pays:     200 + 10 = 210 EGP
Store commission:  200 × 10% = 20 EGP
Store receives:    200 - 20 = 180 EGP
Rider receives:    10 EGP
App commission:    20 EGP
Points earned:     floor(200/100) = 2
Personal (store):  200 × 5% = 10 EGP
Personal (delivery): 10 × 15% = 1.5 EGP
```

### Scenario 2: Order With Points Redemption

```
Subtotal: 300 EGP | Delivery: 10 EGP | Points used: 15

Customer pays:     300 + 10 - 15 = 295 EGP
Store commission:  300 × 10% = 30 EGP
Store receives:    300 - 30 = 270 EGP
Rider receives:    10 EGP
App commission:    30 - 15 = 15 EGP  ← REDUCED
Points earned:     floor(300/100) = 3
Settlement credit: +15 EGP to store  ← APP PAYS THIS
Personal (store):  300 × 5% = 15 EGP
Personal (delivery): 10 × 15% = 1.5 EGP
```

### Scenario 3: Free Delivery Order With Points

```
Subtotal: 500 EGP | Delivery: 0 (free) | Points used: 20

Customer pays:     500 + 0 - 20 = 480 EGP
Store commission:  500 × 10% = 50 EGP
Store receives:    500 - 50 = 450 EGP
Rider receives:    10 EGP (rider still gets paid)
App commission:    50 - 20 - 10 = 20 EGP  ← REDUCED by points AND free delivery
Points earned:     floor(500/100) = 5
Settlement credit: +20 EGP to store (points) +10 EGP free delivery
Personal (store):  500 × 5% = 25 EGP
Personal (delivery): 0 EGP (free delivery)
```

### Scenario 4: Small Order, No Points Earned

```
Subtotal: 80 EGP | Delivery: 10 EGP | Points: 0

Customer pays:     80 + 10 = 90 EGP
Store commission:  80 × 10% = 8 EGP
Store receives:    80 - 8 = 72 EGP
Rider receives:    10 EGP
App commission:    8 EGP
Points earned:     floor(80/100) = 0  ← Below threshold
Personal (store):  80 × 5% = 4 EGP
Personal (delivery): 10 × 15% = 1.5 EGP
```

---

*Document Version: 1.0*
*Last Updated: February 9, 2026*
*For: Backend Development Team*