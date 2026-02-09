# Baladi MVP - Production-Ready Architecture

## Zero-Cost, Village-Scale Delivery Application

---

## Executive Summary

Baladi is a realistic, buildable MVP for daily needs delivery in a small community. This architecture prioritizes:
- **Zero paid services** (no SMS, no maps, no Redis)
- **Cash-only operations**
- **Firebase free tier** for push notifications
- **PostgreSQL** for data storage
- **Village-friendly UX** with simple language and big buttons

---

## Table of Contents

1. [System Architecture](#1-system-architecture)
2. [Database Schema](#2-database-schema)
3. [API Endpoints](#3-api-endpoints)
4. [Order Lifecycle](#4-order-lifecycle)
5. [Weekly Settlement](#5-weekly-settlement)
6. [Flutter Project Structure](#6-flutter-project-structure)
7. [Backend Structure](#7-backend-structure)
8. [UI/UX Design](#8-uiux-design)

---

## 1. System Architecture

### 1.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐       │
│  │ Customer  │ │   Shop    │ │   Rider   │ │   Admin   │       │
│  │   Views   │ │   Views   │ │   Views   │ │   Views   │       │
│  └─────┬─────┘ └─────┬─────┘ └─────┬─────┘ └─────┬─────┘       │
│        └─────────────┴─────────────┴─────────────┘             │
│                           │                                     │
│               ┌───────────▼───────────┐                        │
│               │     VIEW MODELS       │                        │
│               │  State Management     │                        │
│               └───────────┬───────────┘                        │
│                           │                                     │
│               ┌───────────▼───────────┐                        │
│               │      USE CASES        │                        │
│               │   Business Logic      │                        │
│               └───────────┬───────────┘                        │
│                           │                                     │
│               ┌───────────▼───────────┐                        │
│               │    REPOSITORIES       │                        │
│               │   Data Abstraction    │                        │
│               └───────────┬───────────┘                        │
│                           │                                     │
│               ┌───────────▼───────────┐                        │
│               │    DATA SOURCES       │                        │
│               │  Remote + Local       │                        │
│               └───────────┬───────────┘                        │
└───────────────────────────┼─────────────────────────────────────┘
                            │ HTTPS
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     BACKEND SERVER                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    REST API                              │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │
│  │  │  Auth   │ │ Orders  │ │ Points  │ │ Settle  │       │   │
│  │  │ Routes  │ │ Routes  │ │ Routes  │ │ Routes  │       │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   SERVICES                               │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │
│  │  │  Auth   │ │  Order  │ │ Points  │ │  FCM    │       │   │
│  │  │ Service │ │ Engine  │ │ Engine  │ │ Service │       │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     POSTGRESQL                                  │
│                                                                 │
│   Users │ Shops │ Riders │ Orders │ Points │ Settlements       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                 FIREBASE (Free Tier)                            │
│                                                                 │
│              Cloud Messaging (Push Notifications)               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Technology Stack

| Component | Technology | Cost |
|-----------|------------|------|
| Mobile App | Flutter | Free |
| State Management | Cubit (flutter_bloc) | Free |
| Backend | Node.js + Express | Free |
| Database | PostgreSQL | Free (self-hosted) |
| Push Notifications | Firebase Cloud Messaging | Free |
| Hosting | VPS (DigitalOcean/Vultr) | ~$5/month |

### 1.3 MVP Constraints

```
✅ INCLUDED IN MVP:
- Phone + PIN authentication (no OTP)
- Security question for PIN recovery
- Manual text address entry
- Cash-only payments
- Firebase push notifications
- Basic loyalty points
- Simple referral system
- Weekly settlements
- Basic ads (daily offers)

❌ NOT IN MVP (Future):
- Map integration
- OTP/SMS verification
- Online payments
- Redis caching
- Advanced analytics
- Delivery tracking on map
```

---

## 2. Database Schema

### 2.1 Entity Relationship Diagram

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │       │    shops     │       │   riders     │
├──────────────┤       ├──────────────┤       ├──────────────┤
│ id           │       │ id           │       │ id           │
│ role         │──┐    │ user_id      │───────│ user_id      │
│ phone        │  │    │ name         │       │ name         │
│ username     │  │    │ category_id  │───┐   │ phone        │
│ pin_hash     │  │    │ commission   │   │   │ is_available │
│ password_hash│  │    │ is_active    │   │   │ is_active    │
│ security_ans │  │    └──────────────┘   │   └──────────────┘
│ fcm_token    │  │                       │
└──────────────┘  │    ┌──────────────┐   │
                  │    │  categories  │◄──┘
┌──────────────┐  │    ├──────────────┤
│  customers   │  │    │ id           │
├──────────────┤  │    │ name         │
│ id           │  │    │ slug         │
│ user_id      │◄─┘    │ icon         │
│ name         │       └──────────────┘
│ address_text │
│ landmark     │       ┌──────────────┐
│ total_points │       │   products   │
│ referral_code│       ├──────────────┤
└──────────────┘       │ id           │
        │              │ shop_id      │───────┐
        │              │ name         │       │
        ▼              │ price        │       │
┌──────────────┐       │ is_available │       │
│   orders     │       └──────────────┘       │
├──────────────┤                              │
│ id           │       ┌──────────────┐       │
│ order_number │       │ order_items  │       │
│ customer_id  │◄──────│ order_id     │       │
│ shop_id      │───────│ product_id   │───────┘
│ rider_id     │       │ quantity     │
│ status       │       │ price        │
│ subtotal     │       └──────────────┘
│ delivery_fee │
│ points_used  │       ┌──────────────┐
│ total        │       │ settlements  │
│ period_id    │───────│ period_id    │
└──────────────┘       │ shop_id      │
                       │ totals...    │
                       └──────────────┘
```

### 2.2 Complete Table Definitions

#### users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role VARCHAR(20) NOT NULL CHECK (role IN ('customer', 'shop', 'rider', 'admin')),
    phone VARCHAR(20) UNIQUE,
    username VARCHAR(50) UNIQUE,
    pin_hash VARCHAR(255),
    password_hash VARCHAR(255),
    security_answer_hash VARCHAR(255),
    fcm_token VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_users_username ON users(username) WHERE username IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);
```

#### customers
```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    address_text TEXT,
    landmark VARCHAR(255),
    area VARCHAR(100),
    total_points INTEGER DEFAULT 0,
    referral_code VARCHAR(10) UNIQUE NOT NULL,
    referred_by_id UUID REFERENCES customers(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_customers_referral ON customers(referral_code);
```

#### categories
```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    name_ar VARCHAR(50) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(7),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO categories (name, name_ar, slug, icon, color, sort_order) VALUES
('Restaurants', 'مطاعم', 'restaurants', 'restaurant', '#FF6B35', 1),
('Bakeries', 'مخابز', 'bakeries', 'bakery', '#F7C59F', 2),
('Pharmacies', 'صيدليات', 'pharmacies', 'pharmacy', '#2EC4B6', 3),
('Cosmetics', 'مستحضرات تجميل', 'cosmetics', 'cosmetics', '#E71D73', 4),
('Daily Habit', 'احتياجات يومية', 'daily-habit', 'shopping', '#7B2CBF', 5);
```

#### shops
```sql
CREATE TABLE shops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    category_id UUID NOT NULL REFERENCES categories(id),
    description TEXT,
    phone VARCHAR(20),
    address TEXT,
    commission_rate DECIMAL(5,2) DEFAULT 10.00,
    min_order_amount DECIMAL(10,2) DEFAULT 0,
    is_open BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_shops_category ON shops(category_id);
CREATE INDEX idx_shops_active ON shops(is_active, is_open);
```

#### riders
```sql
CREATE TABLE riders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    delivery_fee DECIMAL(10,2) DEFAULT 10.00,
    is_available BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    total_deliveries INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_riders_available ON riders(is_available, is_active);
```

#### products
```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(500),
    is_available BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_products_shop ON products(shop_id, is_available);
```

#### weekly_periods
```sql
CREATE TABLE weekly_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    week_number INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'closed', 'settled')),
    closed_at TIMESTAMP,
    closed_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(year, week_number)
);

CREATE INDEX idx_periods_status ON weekly_periods(status);
CREATE INDEX idx_periods_dates ON weekly_periods(start_date, end_date);
```

#### orders
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES customers(id),
    shop_id UUID NOT NULL REFERENCES shops(id),
    rider_id UUID REFERENCES riders(id),
    period_id UUID REFERENCES weekly_periods(id),
    
    status VARCHAR(20) DEFAULT 'pending' 
        CHECK (status IN ('pending', 'accepted', 'preparing', 'picked_up', 'shop_paid', 'completed', 'cancelled')),
    
    delivery_address TEXT NOT NULL,
    delivery_landmark VARCHAR(255),
    delivery_area VARCHAR(100),
    customer_notes TEXT,
    
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    is_free_delivery BOOLEAN DEFAULT false,
    points_used INTEGER DEFAULT 0,
    points_discount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    shop_commission DECIMAL(10,2) DEFAULT 0,
    admin_commission DECIMAL(10,2) DEFAULT 0,
    points_earned INTEGER DEFAULT 0,
    
    cash_collected BOOLEAN DEFAULT false,
    cash_to_shop BOOLEAN DEFAULT false,
    shop_confirmed_cash BOOLEAN DEFAULT false,
    
    cancellation_reason TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    accepted_at TIMESTAMP,
    preparing_at TIMESTAMP,
    picked_up_at TIMESTAMP,
    shop_paid_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

CREATE INDEX idx_orders_customer ON orders(customer_id, created_at DESC);
CREATE INDEX idx_orders_shop ON orders(shop_id, created_at DESC);
CREATE INDEX idx_orders_rider ON orders(rider_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_period ON orders(period_id);
```

#### order_items
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    subtotal DECIMAL(10,2) NOT NULL,
    notes TEXT
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
```

#### order_status_history
```sql
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    changed_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_status_history_order ON order_status_history(order_id);
```

#### points_transactions
```sql
CREATE TABLE points_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id),
    order_id UUID REFERENCES orders(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('earned', 'redeemed', 'referral', 'adjustment')),
    points INTEGER NOT NULL,
    balance_after INTEGER NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_points_customer ON points_transactions(customer_id, created_at DESC);
```

#### referrals
```sql
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID NOT NULL REFERENCES customers(id),
    referred_id UUID NOT NULL REFERENCES customers(id),
    first_order_id UUID REFERENCES orders(id),
    points_awarded BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE INDEX idx_referrals_referrer ON referrals(referrer_id);
```

#### shop_settlements
```sql
CREATE TABLE shop_settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES shops(id),
    period_id UUID NOT NULL REFERENCES weekly_periods(id),
    
    total_orders INTEGER DEFAULT 0,
    completed_orders INTEGER DEFAULT 0,
    cancelled_orders INTEGER DEFAULT 0,
    
    gross_sales DECIMAL(12,2) DEFAULT 0,
    total_commission DECIMAL(12,2) DEFAULT 0,
    points_discounts DECIMAL(12,2) DEFAULT 0,
    free_delivery_cost DECIMAL(12,2) DEFAULT 0,
    ads_cost DECIMAL(12,2) DEFAULT 0,
    net_amount DECIMAL(12,2) DEFAULT 0,
    
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'settled')),
    settled_at TIMESTAMP,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(shop_id, period_id)
);

CREATE INDEX idx_shop_settlements_period ON shop_settlements(period_id);
```

#### rider_settlements
```sql
CREATE TABLE rider_settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID NOT NULL REFERENCES riders(id),
    period_id UUID NOT NULL REFERENCES weekly_periods(id),
    
    total_deliveries INTEGER DEFAULT 0,
    total_earnings DECIMAL(12,2) DEFAULT 0,
    total_cash_handled DECIMAL(12,2) DEFAULT 0,
    
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'settled')),
    settled_at TIMESTAMP,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(rider_id, period_id)
);

CREATE INDEX idx_rider_settlements_period ON rider_settlements(period_id);
```

#### ads
```sql
CREATE TABLE ads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES shops(id),
    title VARCHAR(100) NOT NULL,
    title_ar VARCHAR(100),
    description TEXT,
    image_url VARCHAR(500),
    daily_cost DECIMAL(10,2) DEFAULT 10.00,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    total_cost DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_ads_shop ON ads(shop_id);
CREATE INDEX idx_ads_active ON ads(is_active, start_date, end_date);
```

#### audit_logs
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    details JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
```

#### notifications
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(100) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
```

---

## 3. API Endpoints

### 3.1 Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/auth/customer/register` | Register customer with phone + PIN | No |
| POST | `/api/auth/customer/login` | Login with phone + PIN | No |
| POST | `/api/auth/customer/recover-pin` | Recover PIN via security question | No |
| POST | `/api/auth/login` | Login for shop/rider/admin | No |
| POST | `/api/auth/refresh` | Refresh JWT token | Yes |
| POST | `/api/auth/logout` | Logout | Yes |
| PUT | `/api/auth/fcm-token` | Update FCM token | Yes |

### 3.2 Customer

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/customer/profile` | Get profile |
| PUT | `/api/customer/profile` | Update profile |
| PUT | `/api/customer/address` | Update address |
| GET | `/api/customer/points` | Get points balance |
| GET | `/api/customer/points/history` | Get points history |
| GET | `/api/customer/referral` | Get referral code |
| POST | `/api/customer/referral/apply` | Apply referral code |

### 3.3 Catalog

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | List categories |
| GET | `/api/categories/:slug/shops` | List shops in category |
| GET | `/api/shops/:id` | Get shop details |
| GET | `/api/shops/:id/products` | Get shop products |

### 3.4 Orders

| Method | Endpoint | Description | Roles |
|--------|----------|-------------|-------|
| POST | `/api/orders` | Create order | Customer |
| GET | `/api/orders` | List my orders | All |
| GET | `/api/orders/:id` | Get order details | All |
| POST | `/api/orders/:id/accept` | Accept order | Shop |
| POST | `/api/orders/:id/preparing` | Start preparing | Shop |
| POST | `/api/orders/:id/assign-rider` | Assign rider | Shop/Admin |
| POST | `/api/orders/:id/pickup` | Mark picked up | Rider |
| POST | `/api/orders/:id/deliver` | Mark delivered | Rider |
| POST | `/api/orders/:id/cash-to-shop` | Cash handed to shop | Rider |
| POST | `/api/orders/:id/confirm-cash` | Confirm cash received | Shop |
| POST | `/api/orders/:id/cancel` | Cancel order | Customer/Shop/Admin |

### 3.5 Shop Management

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

### 3.6 Rider

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/rider/profile` | Get profile |
| PUT | `/api/rider/status` | Toggle availability |
| GET | `/api/rider/orders/available` | List available orders |
| GET | `/api/rider/orders` | List my orders |
| GET | `/api/rider/dashboard` | Get dashboard stats |
| GET | `/api/rider/earnings` | Get earnings |
| GET | `/api/rider/settlements` | List settlements |

### 3.7 Ads

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/ads/active` | List active ads |
| POST | `/api/shop/ads` | Create ad |
| GET | `/api/shop/ads` | List shop ads |
| PUT | `/api/shop/ads/:id` | Update ad |
| DELETE | `/api/shop/ads/:id` | Delete ad |

### 3.8 Admin

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/dashboard` | Get admin dashboard |
| GET | `/api/admin/users` | List all users |
| PUT | `/api/admin/users/:id/activate` | Activate/deactivate user |
| POST | `/api/admin/users/:id/reset-password` | Reset password |
| GET | `/api/admin/shops` | List all shops |
| POST | `/api/admin/shops` | Create shop |
| PUT | `/api/admin/shops/:id` | Update shop |
| GET | `/api/admin/riders` | List all riders |
| POST | `/api/admin/riders` | Create rider |
| PUT | `/api/admin/riders/:id` | Update rider |
| GET | `/api/admin/orders` | List all orders |
| GET | `/api/admin/periods` | List weekly periods |
| POST | `/api/admin/periods/close` | Close current week |
| GET | `/api/admin/settlements` | List all settlements |
| POST | `/api/admin/settlements/:id/settle` | Mark as settled |
| POST | `/api/admin/points/adjust` | Adjust customer points |

---

## 4. Order Lifecycle

### 4.1 Status Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      ORDER LIFECYCLE                            │
└─────────────────────────────────────────────────────────────────┘

  Customer places order
         │
         ▼
    ┌─────────┐
    │ PENDING │ ◄─── Order created, waiting for shop
    └────┬────┘
         │ Shop accepts
         ▼
    ┌──────────┐
    │ ACCEPTED │ ◄─── Shop confirmed, will prepare
    └────┬─────┘
         │ Shop starts preparing
         ▼
    ┌───────────┐
    │ PREPARING │ ◄─── Food/items being prepared
    └─────┬─────┘
         │ Rider picks up
         ▼
    ┌───────────┐
    │ PICKED_UP │ ◄─── Rider has the order, en route
    └─────┬─────┘
         │ Rider delivers & hands cash to shop
         ▼
    ┌───────────┐
    │ SHOP_PAID │ ◄─── Cash transferred to shop
    └─────┬─────┘
         │ Shop confirms cash received
         ▼
    ┌───────────┐
    │ COMPLETED │ ◄─── Order fully closed
    └───────────┘

    ┌───────────┐
    │ CANCELLED │ ◄─── Can happen from: Pending, Accepted
    └───────────┘
```

### 4.2 Order Sequence Diagram

```
Customer          App              API            Shop           Rider           FCM
    │               │                │              │               │              │
    │ Place Order   │                │              │               │              │
    │──────────────►│                │              │               │              │
    │               │ POST /orders   │              │               │              │
    │               │───────────────►│              │               │              │
    │               │                │ Create Order │               │              │
    │               │                │──────────────│               │              │
    │               │                │ Notify Shop  │               │              │
    │               │                │──────────────┼───────────────┼─────────────►│
    │               │                │              │◄──────────────┼──────────────│
    │               │  Order Created │              │               │              │
    │◄──────────────│◄───────────────│              │               │              │
    │               │                │              │               │              │
    │               │                │              │ Accept Order  │              │
    │               │                │◄─────────────│               │              │
    │               │                │ Notify Cust  │               │              │
    │◄──────────────┼────────────────┼──────────────┼───────────────┼──────────────│
    │               │                │              │               │              │
    │               │                │              │ Start Prep    │              │
    │               │                │◄─────────────│               │              │
    │◄──────────────┼────────────────┼──────────────┼───────────────┼──────────────│
    │               │                │              │               │              │
    │               │                │              │ Assign Rider  │              │
    │               │                │──────────────┼───────────────┼─────────────►│
    │               │                │              │               │◄─────────────│
    │               │                │              │               │              │
    │               │                │              │               │ Accept Job   │
    │               │                │◄─────────────┼───────────────│              │
    │               │                │              │               │              │
    │               │                │              │               │ Pickup       │
    │               │                │◄─────────────┼───────────────│              │
    │◄──────────────┼────────────────┼──────────────┼───────────────┼──────────────│
    │               │                │              │               │              │
    │ ════════════════════════════ DELIVERY ═══════════════════════════════════   │
    │               │                │              │               │              │
    │  Cash Payment │                │              │               │              │
    │──────────────────────────────────────────────────────────────►│              │
    │               │                │              │               │              │
    │               │                │              │               │ Mark Deliver │
    │               │                │◄─────────────┼───────────────│              │
    │               │                │              │               │              │
    │               │                │              │◄──────────────│ Hand Cash    │
    │               │                │              │               │              │
    │               │                │              │               │ Confirm Cash │
    │               │                │◄─────────────┼───────────────│              │
    │               │                │              │               │              │
    │               │                │              │ Confirm Rcvd  │              │
    │               │                │◄─────────────│               │              │
    │               │                │ Complete Ord │               │              │
    │               │                │──────────────│               │              │
    │               │                │ Award Points │               │              │
    │◄──────────────┼────────────────┼──────────────┼───────────────┼──────────────│
    │               │                │              │               │              │
```

### 4.3 Points & Commission Calculations

```
POINTS EARNED:
  points = floor(subtotal / 100)
  Example: 350 EGP order = 3 points

REFERRAL BONUS:
  2 points to referrer when referred user completes first order

POINTS REDEMPTION:
  1 point = 1 EGP discount
  Discount deducted from Admin commission ONLY

COMMISSION CALCULATION:
  shop_commission = subtotal × commission_rate (e.g., 10%)
  admin_commission = shop_commission - points_discount - free_delivery_cost

EXAMPLE:
  Order subtotal: 200 EGP
  Delivery fee: 15 EGP
  Points used: 10 points (10 EGP discount)
  Shop commission rate: 10%
  
  shop_commission = 200 × 0.10 = 20 EGP
  admin_commission = 20 - 10 = 10 EGP
  
  Customer pays: 200 + 15 - 10 = 205 EGP
  Shop receives: 200 - 20 = 180 EGP
  Rider receives: 15 EGP
  Admin receives: 10 EGP
```

---

## 5. Weekly Settlement

### 5.1 Week Period

```
FIXED WEEK:
  Start: Saturday 00:00:00 (Cairo Time)
  End:   Friday 23:59:59 (Cairo Time)

Week Number: Based on ISO week of the year
Year: Current year

PERIOD STATUSES:
  - active:   Current week, orders being placed
  - closed:   Admin closed the week, no new orders in this period
  - settled:  All settlements paid and confirmed
```

### 5.2 Settlement Flow

```
Admin                    API                    Database
  │                       │                        │
  │ GET /admin/dashboard  │                        │
  │──────────────────────►│                        │
  │                       │ Get current period     │
  │                       │───────────────────────►│
  │                       │ Get period stats       │
  │                       │───────────────────────►│
  │   Dashboard data      │                        │
  │◄──────────────────────│                        │
  │                       │                        │
  │ POST /periods/close   │                        │
  │──────────────────────►│                        │
  │                       │ Calculate shop settles │
  │                       │───────────────────────►│
  │                       │                        │
  │                       │ For each shop:         │
  │                       │ - Sum completed orders │
  │                       │ - Calculate commission │
  │                       │ - Sum points discounts │
  │                       │ - Sum free deliveries  │
  │                       │ - Sum ads costs        │
  │                       │ - Create settlement    │
  │                       │───────────────────────►│
  │                       │                        │
  │                       │ Calculate rider settles│
  │                       │ For each rider:        │
  │                       │ - Sum deliveries       │
  │                       │ - Sum earnings         │
  │                       │ - Create settlement    │
  │                       │───────────────────────►│
  │                       │                        │
  │                       │ Mark period closed     │
  │                       │───────────────────────►│
  │                       │                        │
  │                       │ Create new period      │
  │                       │───────────────────────►│
  │                       │                        │
  │                       │ Send notifications     │
  │                       │───────────────────────►│
  │   Week closed         │                        │
  │◄──────────────────────│                        │
  │                       │                        │
```

### 5.3 Settlement Report Structure

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
  "summary": {
    "total_orders": 145,
    "completed_orders": 138,
    "cancelled_orders": 7,
    "gross_sales": 24500,
    "total_delivery_fees": 2070,
    "total_shop_commissions": 2450,
    "total_points_redeemed": 180,
    "total_free_deliveries": 8,
    "free_delivery_cost": 120,
    "total_ads_revenue": 280,
    "admin_net_revenue": 2430
  },
  "shop_settlements": [
    {
      "shop_name": "Fresh Bakery",
      "total_orders": 42,
      "gross_sales": 7800,
      "commission": 780,
      "points_discounts": 45,
      "ads_cost": 70,
      "net_payable": 6905
    }
  ],
  "rider_settlements": [
    {
      "rider_name": "Mohamed",
      "deliveries": 35,
      "earnings": 525,
      "cash_handled": 8200
    }
  ]
}
```

---

## 6. Flutter Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_endpoints.dart
│   │   └── storage_keys.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── helpers.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_response.dart
│   │   └── api_exception.dart
│   │
│   ├── errors/
│   │   └── failures.dart
│   │
│   └── di/
│       └── injection.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── customer_model.dart
│   │   ├── shop_model.dart
│   │   ├── rider_model.dart
│   │   ├── product_model.dart
│   │   ├── order_model.dart
│   │   ├── order_item_model.dart
│   │   ├── category_model.dart
│   │   ├── points_model.dart
│   │   ├── settlement_model.dart
│   │   ├── ad_model.dart
│   │   └── notification_model.dart
│   │
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── auth_remote_ds.dart
│   │   │   ├── customer_remote_ds.dart
│   │   │   ├── shop_remote_ds.dart
│   │   │   ├── rider_remote_ds.dart
│   │   │   ├── order_remote_ds.dart
│   │   │   └── admin_remote_ds.dart
│   │   │
│   │   └── local/
│   │       ├── auth_local_ds.dart
│   │       └── cache_ds.dart
│   │
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── customer_repository_impl.dart
│       ├── shop_repository_impl.dart
│       ├── rider_repository_impl.dart
│       ├── order_repository_impl.dart
│       └── admin_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── customer.dart
│   │   ├── shop.dart
│   │   ├── rider.dart
│   │   ├── product.dart
│   │   ├── order.dart
│   │   ├── category.dart
│   │   └── settlement.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── customer_repository.dart
│   │   ├── shop_repository.dart
│   │   ├── rider_repository.dart
│   │   ├── order_repository.dart
│   │   └── admin_repository.dart
│   │
│   └── usecases/
│       ├── auth/
│       │   ├── login_customer.dart
│       │   ├── register_customer.dart
│       │   ├── recover_pin.dart
│       │   ├── login_user.dart
│       │   └── logout.dart
│       │
│       ├── customer/
│       │   ├── get_profile.dart
│       │   ├── update_address.dart
│       │   ├── get_points.dart
│       │   └── apply_referral.dart
│       │
│       ├── catalog/
│       │   ├── get_categories.dart
│       │   ├── get_shops.dart
│       │   └── get_products.dart
│       │
│       ├── order/
│       │   ├── create_order.dart
│       │   ├── get_orders.dart
│       │   ├── update_order_status.dart
│       │   └── cancel_order.dart
│       │
│       ├── shop/
│       │   ├── get_shop_orders.dart
│       │   ├── manage_products.dart
│       │   └── get_settlement.dart
│       │
│       ├── rider/
│       │   ├── get_available_orders.dart
│       │   ├── accept_delivery.dart
│       │   └── get_earnings.dart
│       │
│       └── admin/
│           ├── get_dashboard.dart
│           ├── manage_users.dart
│           └── close_week.dart
│
├── presentation/
│   ├── cubits/
│   │   ├── auth/
│   │   │   ├── auth_cubit.dart
│   │   │   └── auth_state.dart
│   │   ├── customer/
│   │   │   ├── customer_cubit.dart
│   │   │   └── customer_state.dart
│   │   ├── shop/
│   │   │   ├── shop_cubit.dart
│   │   │   └── shop_state.dart
│   │   ├── rider/
│   │   │   ├── rider_cubit.dart
│   │   │   └── rider_state.dart
│   │   ├── order/
│   │   │   ├── order_cubit.dart
│   │   │   └── order_state.dart
│   │   └── admin/
│   │       ├── admin_cubit.dart
│   │       └── admin_state.dart
│   │
│   ├── common/
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_card.dart
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   └── empty_state.dart
│   │   │
│   │   └── layouts/
│   │       └── base_scaffold.dart
│   │
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── customer_login_screen.dart
│   │   │   ├── customer_register_screen.dart
│   │   │   ├── pin_recovery_screen.dart
│   │   │   └── staff_login_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── pin_input.dart
│   │       └── phone_input.dart
│   │
│   ├── customer/
│   │   ├── screens/
│   │   │   ├── customer_home_screen.dart
│   │   │   ├── category_shops_screen.dart
│   │   │   ├── shop_details_screen.dart
│   │   │   ├── cart_screen.dart
│   │   │   ├── checkout_screen.dart
│   │   │   ├── order_details_screen.dart
│   │   │   ├── orders_history_screen.dart
│   │   │   ├── points_screen.dart
│   │   │   ├── referral_screen.dart
│   │   │   └── profile_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── category_card.dart
│   │       ├── shop_card.dart
│   │       ├── product_card.dart
│   │       ├── cart_item.dart
│   │       └── order_status_badge.dart
│   │
│   ├── shop/
│   │   ├── screens/
│   │   │   ├── shop_dashboard_screen.dart
│   │   │   ├── shop_orders_screen.dart
│   │   │   ├── order_manage_screen.dart
│   │   │   ├── products_screen.dart
│   │   │   ├── product_form_screen.dart
│   │   │   ├── shop_settings_screen.dart
│   │   │   └── shop_settlements_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── order_card.dart
│   │       ├── product_tile.dart
│   │       └── stats_card.dart
│   │
│   ├── rider/
│   │   ├── screens/
│   │   │   ├── rider_dashboard_screen.dart
│   │   │   ├── available_orders_screen.dart
│   │   │   ├── current_delivery_screen.dart
│   │   │   ├── rider_earnings_screen.dart
│   │   │   └── rider_profile_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── delivery_card.dart
│   │       └── earnings_summary.dart
│   │
│   └── admin/
│       ├── screens/
│       │   ├── admin_dashboard_screen.dart
│       │   ├── users_screen.dart
│       │   ├── shops_manage_screen.dart
│       │   ├── riders_manage_screen.dart
│       │   ├── all_orders_screen.dart
│       │   ├── weekly_periods_screen.dart
│       │   ├── settlements_screen.dart
│       │   └── points_manage_screen.dart
│       │
│       └── widgets/
│           ├── user_tile.dart
│           ├── period_card.dart
│           └── settlement_card.dart
│
└── routes/
    ├── app_router.dart
    └── route_guards.dart
```

---

## 7. Backend Structure

```
backend/
├── src/
│   ├── index.js                 # Entry point
│   ├── app.js                   # Express app setup
│   │
│   ├── config/
│   │   ├── database.js          # PostgreSQL connection
│   │   ├── firebase.js          # Firebase Admin SDK
│   │   └── env.js               # Environment variables
│   │
│   ├── middleware/
│   │   ├── auth.js              # JWT verification
│   │   ├── role.js              # Role-based access
│   │   ├── validate.js          # Request validation
│   │   └── error.js             # Error handling
│   │
│   ├── routes/
│   │   ├── index.js             # Route aggregator
│   │   ├── auth.routes.js
│   │   ├── customer.routes.js
│   │   ├── catalog.routes.js
│   │   ├── order.routes.js
│   │   ├── shop.routes.js
│   │   ├── rider.routes.js
│   │   ├── ads.routes.js
│   │   └── admin.routes.js
│   │
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── customer.controller.js
│   │   ├── catalog.controller.js
│   │   ├── order.controller.js
│   │   ├── shop.controller.js
│   │   ├── rider.controller.js
│   │   ├── ads.controller.js
│   │   └── admin.controller.js
│   │
│   ├── services/
│   │   ├── auth.service.js
│   │   ├── order.service.js
│   │   ├── points.service.js
│   │   ├── settlement.service.js
│   │   ├── notification.service.js
│   │   └── audit.service.js
│   │
│   ├── repositories/
│   │   ├── user.repository.js
│   │   ├── customer.repository.js
│   │   ├── shop.repository.js
│   │   ├── rider.repository.js
│   │   ├── product.repository.js
│   │   ├── order.repository.js
│   │   ├── points.repository.js
│   │   ├── settlement.repository.js
│   │   └── ads.repository.js
│   │
│   ├── models/
│   │   └── index.js             # SQL queries / ORM models
│   │
│   └── utils/
│       ├── jwt.js
│       ├── hash.js
│       ├── generators.js
│       └── date.js
│
├── migrations/
│   └── 001_initial_schema.sql
│
├── seeds/
│   └── categories.sql
│
├── tests/
│   └── ...
│
├── package.json
├── .env.example
└── README.md
```

---

## 8. UI/UX Design

### 8.1 Color Palette

```dart
class AppColors {
  // Primary - Warm & Trustworthy
  static const Color primary = Color(0xFF2D5A27);      // Forest Green
  static const Color primaryLight = Color(0xFF4A7C43); // Light Green
  static const Color primaryDark = Color(0xFF1A3A16);  // Dark Green
  
  // Secondary - Warm Accent
  static const Color secondary = Color(0xFFD4A574);    // Warm Sand
  static const Color secondaryLight = Color(0xFFE8C9A0);
  
  // Background
  static const Color background = Color(0xFFFAF8F5);   // Warm White
  static const Color surface = Color(0xFFFFFFFF);      // Pure White
  static const Color surfaceVariant = Color(0xFFF5F2ED);
  
  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);  // Near Black
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Order Status Colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusAccepted = Color(0xFF2196F3);
  static const Color statusPreparing = Color(0xFF9C27B0);
  static const Color statusPickedUp = Color(0xFF00BCD4);
  static const Color statusShopPaid = Color(0xFF8BC34A);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFE53935);
  
  // Category Colors
  static const Color categoryRestaurants = Color(0xFFFF6B35);
  static const Color categoryBakeries = Color(0xFFF7C59F);
  static const Color categoryPharmacies = Color(0xFF2EC4B6);
  static const Color categoryCosmetics = Color(0xFFE71D73);
  static const Color categoryDailyHabit = Color(0xFF7B2CBF);
}
```

### 8.2 Typography

```dart
class AppTextStyles {
  static const String fontFamily = 'Cairo'; // Arabic-friendly font
  
  // Headlines
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  
  // Button
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
```

### 8.3 Component Styles

```dart
// Button Style - Large, Easy to Tap
class AppButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    minimumSize: Size(double.infinity, 56), // Full width, 56px height
  );
  
  static ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    side: BorderSide(color: AppColors.primary, width: 2),
    minimumSize: Size(double.infinity, 56),
  );
}

// Card Style
class AppCardStyles {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}

// Input Style
class AppInputStyles {
  static InputDecoration input = InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  );
}
```

### 8.4 Screen Layouts

#### Customer Home
```
┌─────────────────────────────────────┐
│                                     │
│  ☰  بلدي Baladi            🔔 👤   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📍 التوصيل إلى                     │
│  ┌─────────────────────────────┐   │
│  │  المنزل - شارع النيل، ش...  │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ╔═════════════════════════════╗   │
│  ║                             ║   │
│  ║    عروض اليوم              ║   │
│  ║    Daily Offers            ║   │
│  ║                             ║   │
│  ╚═════════════════════════════╝   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  الأقسام                           │
│                                     │
│  ┌───────┐ ┌───────┐ ┌───────┐    │
│  │  🍕   │ │  🥐   │ │  💊   │    │
│  │مطاعم  │ │ مخابز │ │صيدليات│    │
│  └───────┘ └───────┘ └───────┘    │
│                                     │
│  ┌───────┐ ┌───────┐              │
│  │  💄   │ │  🛒   │              │
│  │تجميل  │ │ يومية │              │
│  └───────┘ └───────┘              │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  💎 نقاطك: 25 نقطة    [استخدم →]   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│   🏠      🔍      🛒      📋      │
│  الرئيسية  بحث   السلة   طلباتي   │
│                                     │
└─────────────────────────────────────┘
```

#### Shop Dashboard
```
┌─────────────────────────────────────┐
│                                     │
│  مخبز الفرح              ⚙️  🔔    │
│  ● مفتوح                           │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  إحصائيات اليوم                    │
│                                     │
│  ┌─────────┐ ┌─────────┐          │
│  │   15    │ │  2,450  │          │
│  │  طلب    │ │  جنيه   │          │
│  └─────────┘ └─────────┘          │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  طلبات جديدة (3)        [عرض الكل] │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ طلب #1234              ⏱️ 5 د  ││
│  │ 3 عناصر • 185 جنيه            ││
│  │                                 ││
│  │ ┌─────────┐  ┌─────────┐      ││
│  │ │  قبول   │  │  رفض   │      ││
│  │ └─────────┘  └─────────┘      ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ملخص الأسبوع                      │
│  ┌─────────────────────────────────┐│
│  │ المبيعات:      12,450 جنيه     ││
│  │ العمولة:       -1,245 جنيه     ││
│  │ ─────────────────────────────  ││
│  │ الصافي:       11,205 جنيه     ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📦        📋        📊        💰  │
│ الطلبات   المنتجات  الإحصائيات  التسوية│
│                                     │
└─────────────────────────────────────┘
```

### 8.5 Design Principles

```
1. VILLAGE-FRIENDLY:
   - Large touch targets (min 48px)
   - Clear, simple Arabic text
   - Minimal text, maximum icons
   - High contrast colors

2. TRUST & CLARITY:
   - Warm, natural colors (greens, earth tones)
   - Clean white backgrounds
   - Clear status indicators
   - Simple navigation

3. PERFORMANCE:
   - No heavy animations
   - Smooth transitions only (200-300ms)
   - Lazy loading for images
   - Minimal network requests

4. ACCESSIBILITY:
   - RTL support for Arabic
   - Readable font sizes (min 14px)
   - Color contrast > 4.5:1
   - Loading states for all actions
```

---

## Quick Reference

### Order Status Colors
| Status | Color | Arabic |
|--------|-------|--------|
| Pending | Orange | قيد الانتظار |
| Accepted | Blue | مقبول |
| Preparing | Purple | جاري التحضير |
| PickedUp | Cyan | تم الاستلام |
| ShopPaid | Light Green | تم الدفع للمتجر |
| Completed | Green | مكتمل |
| Cancelled | Red | ملغي |

### Points Quick Calc
```
100 EGP = 1 point
1 point = 1 EGP discount
Referral bonus = 2 points
```

### Commission Quick Calc
```
Shop Commission = Subtotal × 10%
Admin Net = Commission - Points Discount - Free Delivery
```

---

*Document Version: MVP 1.0*
*Last Updated: January 19, 2026*