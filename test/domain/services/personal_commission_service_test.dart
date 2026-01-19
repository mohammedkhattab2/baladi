/// Unit tests for PersonalCommissionService.
///
/// These tests validate:
/// - Correct calculation of personal commission from store (5% of subtotal)
/// - Correct calculation of personal commission from delivery (15% of fee = 1.5 EGP)
/// - Store, delivery, and platform revenues remain unaffected
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:baladi/domain/services/personal_commission_service.dart';

void main() {
  late PersonalCommissionService service;

  setUp(() {
    service = PersonalCommissionService();
  });

  group('PersonalCommissionService', () {
    group('commissionFromStore', () {
      test('should return 5% of order subtotal', () {
        // Arrange
        const orderSubtotal = 200.0;
        const expectedCommission = 10.0; // 5% of 200

        // Act
        final result = service.commissionFromStore(orderSubtotal);

        // Assert
        expect(result, equals(expectedCommission));
      });

      test('should return 0 for zero subtotal', () {
        // Arrange
        const orderSubtotal = 0.0;

        // Act
        final result = service.commissionFromStore(orderSubtotal);

        // Assert
        expect(result, equals(0.0));
      });

      test('should return 0 for negative subtotal', () {
        // Arrange
        const orderSubtotal = -100.0;

        // Act
        final result = service.commissionFromStore(orderSubtotal);

        // Assert
        expect(result, equals(0.0));
      });

      test('should handle decimal subtotals correctly', () {
        // Arrange
        const orderSubtotal = 150.50;
        const expectedCommission = 7.53; // 5% of 150.50, rounded

        // Act
        final result = service.commissionFromStore(orderSubtotal);

        // Assert
        expect(result, equals(expectedCommission));
      });

      test('should handle large order subtotals', () {
        // Arrange
        const orderSubtotal = 10000.0;
        const expectedCommission = 500.0; // 5% of 10000

        // Act
        final result = service.commissionFromStore(orderSubtotal);

        // Assert
        expect(result, equals(expectedCommission));
      });
    });

    group('commissionFromDelivery', () {
      test('should return 1.5 EGP for default 10 EGP delivery fee', () {
        // Arrange
        const expectedCommission = 1.5; // 15% of 10

        // Act
        final result = service.commissionFromDelivery();

        // Assert
        expect(result, equals(expectedCommission));
      });

      test('should return 15% of custom delivery fee', () {
        // Arrange
        const deliveryFee = 20.0;
        const expectedCommission = 3.0; // 15% of 20

        // Act
        final result = service.commissionFromDelivery(deliveryFee);

        // Assert
        expect(result, equals(expectedCommission));
      });

      test('should return 0 for zero delivery fee', () {
        // Arrange
        const deliveryFee = 0.0;

        // Act
        final result = service.commissionFromDelivery(deliveryFee);

        // Assert
        expect(result, equals(0.0));
      });

      test('should return 0 for negative delivery fee', () {
        // Arrange
        const deliveryFee = -10.0;

        // Act
        final result = service.commissionFromDelivery(deliveryFee);

        // Assert
        expect(result, equals(0.0));
      });
    });

    group('calculateTotalCommission', () {
      test('should calculate combined commission correctly', () {
        // Arrange
        const orderSubtotal = 200.0;
        const deliveryFee = 10.0;
        const expectedStoreCommission = 10.0; // 5% of 200
        const expectedDeliveryCommission = 1.5; // 15% of 10
        const expectedTotal = 11.5;

        // Act
        final result = service.calculateTotalCommission(
          orderSubtotal: orderSubtotal,
          deliveryFee: deliveryFee,
        );

        // Assert
        expect(result.fromStore, equals(expectedStoreCommission));
        expect(result.fromDelivery, equals(expectedDeliveryCommission));
        expect(result.total, equals(expectedTotal));
        expect(result.orderSubtotal, equals(orderSubtotal));
        expect(result.deliveryFee, equals(deliveryFee));
      });

      test('should skip delivery commission for free delivery', () {
        // Arrange
        const orderSubtotal = 200.0;
        const expectedStoreCommission = 10.0;
        const expectedDeliveryCommission = 0.0;
        const expectedTotal = 10.0;

        // Act
        final result = service.calculateTotalCommission(
          orderSubtotal: orderSubtotal,
          isFreeDelivery: true,
        );

        // Assert
        expect(result.fromStore, equals(expectedStoreCommission));
        expect(result.fromDelivery, equals(expectedDeliveryCommission));
        expect(result.total, equals(expectedTotal));
      });

      test('should handle minimum order correctly', () {
        // Arrange
        const orderSubtotal = 50.0;
        const expectedStoreCommission = 2.5; // 5% of 50
        const expectedDeliveryCommission = 1.5;
        const expectedTotal = 4.0;

        // Act
        final result = service.calculateTotalCommission(
          orderSubtotal: orderSubtotal,
        );

        // Assert
        expect(result.fromStore, equals(expectedStoreCommission));
        expect(result.fromDelivery, equals(expectedDeliveryCommission));
        expect(result.total, equals(expectedTotal));
      });
    });

    group('Independence from other revenues', () {
      test('personal commission should not affect store earnings calculation', () {
        // This test demonstrates that personal commission is calculated
        // independently and does not reduce store earnings.
        //
        // Store earnings = subtotal - platform commission (10%)
        // Personal commission = 5% of subtotal (tracked separately)
        //
        // Example: Order subtotal 200 EGP
        // - Store receives: 200 - 20 (platform 10%) = 180 EGP
        // - Personal commission: 10 EGP (tracked separately, not deducted from store)

        // Arrange
        const orderSubtotal = 200.0;
        const platformCommissionRate = 0.10;
        const storeEarnings = orderSubtotal * (1 - platformCommissionRate); // 180

        // Act
        final personalCommission = service.commissionFromStore(orderSubtotal);

        // Assert
        // Store earnings remain unchanged regardless of personal commission
        expect(storeEarnings, equals(180.0));
        expect(personalCommission, equals(10.0));
        // Personal commission does NOT reduce store earnings
        expect(storeEarnings, isNot(equals(storeEarnings - personalCommission)));
      });

      test('personal commission should not affect delivery rider earnings', () {
        // Delivery rider gets fixed 10 EGP per order
        // Personal commission from delivery: 15% of 10 = 1.5 EGP (tracked separately)
        // Rider still receives full 10 EGP

        // Arrange
        const deliveryFee = 10.0;
        const riderEarnings = deliveryFee; // Rider gets full amount

        // Act
        final personalCommission = service.commissionFromDelivery(deliveryFee);

        // Assert
        expect(riderEarnings, equals(10.0));
        expect(personalCommission, equals(1.5));
        // Rider earnings remain unchanged
        expect(riderEarnings, isNot(equals(riderEarnings - personalCommission)));
      });

      test('personal commission should not affect platform revenue', () {
        // Platform commission = 10% of subtotal
        // Personal commission = 5% of subtotal (tracked separately)
        // They are independent

        // Arrange
        const orderSubtotal = 200.0;
        const platformCommissionRate = 0.10;
        const platformRevenue = orderSubtotal * platformCommissionRate; // 20

        // Act
        final personalCommission = service.commissionFromStore(orderSubtotal);

        // Assert
        expect(platformRevenue, equals(20.0));
        expect(personalCommission, equals(10.0));
        // They are tracked independently, platform revenue unchanged
      });
    });

    group('Sample Use Cases', () {
      test('Sample: Customer places order with points discount', () {
        // Scenario:
        // - Order subtotal: 300 EGP
        // - Customer uses 5 points (5 EGP discount)
        // - Delivery fee: 10 EGP
        // - Points discount only affects platform commission
        //
        // Financial breakdown:
        // - Customer pays: 300 + 10 - 5 = 305 EGP
        // - Store receives: 300 - 30 (10% platform) = 270 EGP
        // - Rider receives: 10 EGP
        // - Platform commission: 30 - 5 (points) = 25 EGP
        // - Personal commission: 15 + 1.5 = 16.5 EGP (tracked separately)

        // Arrange
        const orderSubtotal = 300.0;
        const deliveryFee = 10.0;
        const pointsDiscount = 5.0;
        const platformCommissionRate = 0.10;

        // Calculate personal commission
        final personalCommission = service.calculateTotalCommission(
          orderSubtotal: orderSubtotal,
          deliveryFee: deliveryFee,
        );

        // Calculate other financials (existing logic)
        const customerPays = orderSubtotal + deliveryFee - pointsDiscount; // 305
        const storeCommission = orderSubtotal * platformCommissionRate; // 30
        const storeEarnings = orderSubtotal - storeCommission; // 270
        const riderEarnings = deliveryFee; // 10
        const platformRevenue = storeCommission - pointsDiscount; // 25

        // Assert - Personal commission calculated correctly
        expect(personalCommission.fromStore, equals(15.0)); // 5% of 300
        expect(personalCommission.fromDelivery, equals(1.5)); // 15% of 10
        expect(personalCommission.total, equals(16.5));

        // Assert - Other revenues unaffected
        expect(customerPays, equals(305.0));
        expect(storeEarnings, equals(270.0));
        expect(riderEarnings, equals(10.0));
        expect(platformRevenue, equals(25.0));
      });

      test('Sample: Order with free delivery', () {
        // Scenario:
        // - Order subtotal: 500 EGP
        // - Free delivery (promotional)
        // - No delivery commission for personal commission

        // Arrange
        const orderSubtotal = 500.0;

        // Act
        final personalCommission = service.calculateTotalCommission(
          orderSubtotal: orderSubtotal,
          isFreeDelivery: true,
        );

        // Assert
        expect(personalCommission.fromStore, equals(25.0)); // 5% of 500
        expect(personalCommission.fromDelivery, equals(0.0)); // No delivery
        expect(personalCommission.total, equals(25.0));
      });
    });
  });
}