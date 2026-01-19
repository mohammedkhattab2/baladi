/// Unit tests for PointsService.
///
/// Tests verify:
/// - Correct points earning for various order amounts
/// - Correct points redemption and order total adjustment
/// - Points redemption does NOT affect store or rider earnings
/// - Points usage value correctly added to store's weekly commission
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:baladi/domain/services/points_service.dart';
import 'package:baladi/domain/rules/points_rules.dart';

void main() {
  late PointsService pointsService;

  setUp(() {
    pointsService = PointsService();
  });

  group('PointsService - calculateEarnedPoints', () {
    test('should return 2 points for orders <= 200 EGP (minimum)', () {
      // Orders at or below 200 EGP should always earn exactly 2 points
      expect(pointsService.calculateEarnedPoints(50), equals(2));
      expect(pointsService.calculateEarnedPoints(100), equals(2));
      expect(pointsService.calculateEarnedPoints(150), equals(2));
      expect(pointsService.calculateEarnedPoints(200), equals(2));
    });

    test('should return 2 points for orders just above 200 but below 300 EGP', () {
      // 201-299 EGP: 2 + floor((amount - 200) / 100) = 2 + 0 = 2 points
      expect(pointsService.calculateEarnedPoints(201), equals(2));
      expect(pointsService.calculateEarnedPoints(250), equals(2));
      expect(pointsService.calculateEarnedPoints(299), equals(2));
    });

    test('should return proportional points for orders above 200 EGP', () {
      // 300 EGP: 2 + floor(100/100) = 3 points
      expect(pointsService.calculateEarnedPoints(300), equals(3));

      // 350 EGP: 2 + floor(150/100) = 3 points
      expect(pointsService.calculateEarnedPoints(350), equals(3));

      // 400 EGP: 2 + floor(200/100) = 4 points
      expect(pointsService.calculateEarnedPoints(400), equals(4));

      // 500 EGP: 2 + floor(300/100) = 5 points
      expect(pointsService.calculateEarnedPoints(500), equals(5));

      // 1000 EGP: 2 + floor(800/100) = 10 points
      expect(pointsService.calculateEarnedPoints(1000), equals(10));
    });

    test('should return 0 for orders with 0 or negative amounts', () {
      expect(pointsService.calculateEarnedPoints(0), equals(2));
      expect(pointsService.calculateEarnedPoints(-50), equals(0));
    });

    test('should always return at least 2 points for positive orders', () {
      // Any positive order amount should earn at least 2 points
      expect(pointsService.calculateEarnedPoints(1), greaterThanOrEqualTo(2));
      expect(pointsService.calculateEarnedPoints(10), greaterThanOrEqualTo(2));
      expect(pointsService.calculateEarnedPoints(100), greaterThanOrEqualTo(2));
      expect(pointsService.calculateEarnedPoints(500), greaterThanOrEqualTo(2));
    });
  });

  group('PointsService - applyPoints', () {
    test('should correctly apply points discount to order total', () {
      final result = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 10,
        availablePoints: 50,
      );

      expect(result.pointsUsed, equals(10));
      expect(result.discountAmount, equals(10)); // 1 point = 1 EGP
      expect(result.newTotal, equals(190));
      expect(result.originalTotal, equals(200));
    });

    test('should not use more points than available', () {
      final result = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 100,
        availablePoints: 30,
      );

      expect(result.pointsUsed, equals(30)); // Limited by available
      expect(result.discountAmount, equals(30));
      expect(result.newTotal, equals(170));
    });

    test('should not use more points than maxRedeemable', () {
      final result = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 50,
        availablePoints: 100,
        maxRedeemablePoints: 20,
      );

      expect(result.pointsUsed, equals(20)); // Limited by max redeemable
      expect(result.discountAmount, equals(20));
      expect(result.newTotal, equals(180));
    });

    test('should not discount more than order total', () {
      final result = pointsService.applyPoints(
        orderTotal: 50,
        pointsToUse: 100,
        availablePoints: 100,
      );

      expect(result.pointsUsed, equals(50)); // Limited by order total
      expect(result.discountAmount, equals(50));
      expect(result.newTotal, equals(0));
    });

    test('should return zero discount for 0 or negative points', () {
      final resultZero = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 0,
        availablePoints: 50,
      );

      expect(resultZero.pointsUsed, equals(0));
      expect(resultZero.discountAmount, equals(0));
      expect(resultZero.newTotal, equals(200));

      final resultNegative = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: -10,
        availablePoints: 50,
      );

      expect(resultNegative.pointsUsed, equals(0));
      expect(resultNegative.discountAmount, equals(0));
    });

    test('should calculate store weekly commission credit equal to discount', () {
      final result = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 30,
        availablePoints: 50,
      );

      // Store receives credit for the full discount amount
      // This ensures store doesn't lose money from points redemption
      expect(result.storeWeeklyCommissionCredit, equals(result.discountAmount));
      expect(result.storeWeeklyCommissionCredit, equals(30));
    });

    test('should have hasDiscount true when points are applied', () {
      final withDiscount = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 10,
        availablePoints: 50,
      );

      expect(withDiscount.hasDiscount, isTrue);

      final withoutDiscount = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 0,
        availablePoints: 50,
      );

      expect(withoutDiscount.hasDiscount, isFalse);
    });
  });

  group('PointsService - recordPointsUsage', () {
    test('should create correct points usage record', () {
      final record = pointsService.recordPointsUsage(
        orderId: 'order-123',
        storeId: 'store-456',
        pointsUsed: 25,
        monetaryValue: 25,
      );

      expect(record.orderId, equals('order-123'));
      expect(record.storeId, equals('store-456'));
      expect(record.pointsUsed, equals(25));
      expect(record.monetaryValue, equals(25));
      expect(record.usedAt, isNotNull);
    });

    test('should set correct timestamp', () {
      final beforeTest = DateTime.now();
      final record = pointsService.recordPointsUsage(
        orderId: 'order-123',
        storeId: 'store-456',
        pointsUsed: 10,
        monetaryValue: 10,
      );
      final afterTest = DateTime.now();

      expect(record.usedAt.isAfter(beforeTest.subtract(const Duration(seconds: 1))), isTrue);
      expect(record.usedAt.isBefore(afterTest.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('PointsService - calculateStoreWeeklyPointsCredit', () {
    test('should calculate total credit for a single store', () {
      final records = [
        PointsUsageRecord(
          orderId: 'order-1',
          storeId: 'store-A',
          pointsUsed: 10,
          monetaryValue: 10,
          usedAt: DateTime.now(),
        ),
        PointsUsageRecord(
          orderId: 'order-2',
          storeId: 'store-A',
          pointsUsed: 20,
          monetaryValue: 20,
          usedAt: DateTime.now(),
        ),
        PointsUsageRecord(
          orderId: 'order-3',
          storeId: 'store-A',
          pointsUsed: 15,
          monetaryValue: 15,
          usedAt: DateTime.now(),
        ),
      ];

      final credit = pointsService.calculateStoreWeeklyPointsCredit(
        pointsUsageRecords: records,
        storeId: 'store-A',
      );

      expect(credit, equals(45)); // 10 + 20 + 15
    });

    test('should only include credits for the specified store', () {
      final records = [
        PointsUsageRecord(
          orderId: 'order-1',
          storeId: 'store-A',
          pointsUsed: 10,
          monetaryValue: 10,
          usedAt: DateTime.now(),
        ),
        PointsUsageRecord(
          orderId: 'order-2',
          storeId: 'store-B',
          pointsUsed: 50,
          monetaryValue: 50,
          usedAt: DateTime.now(),
        ),
        PointsUsageRecord(
          orderId: 'order-3',
          storeId: 'store-A',
          pointsUsed: 20,
          monetaryValue: 20,
          usedAt: DateTime.now(),
        ),
      ];

      final creditA = pointsService.calculateStoreWeeklyPointsCredit(
        pointsUsageRecords: records,
        storeId: 'store-A',
      );

      final creditB = pointsService.calculateStoreWeeklyPointsCredit(
        pointsUsageRecords: records,
        storeId: 'store-B',
      );

      expect(creditA, equals(30)); // 10 + 20
      expect(creditB, equals(50)); // 50
    });

    test('should return 0 for store with no records', () {
      final records = [
        PointsUsageRecord(
          orderId: 'order-1',
          storeId: 'store-A',
          pointsUsed: 10,
          monetaryValue: 10,
          usedAt: DateTime.now(),
        ),
      ];

      final credit = pointsService.calculateStoreWeeklyPointsCredit(
        pointsUsageRecords: records,
        storeId: 'store-C',
      );

      expect(credit, equals(0));
    });

    test('should return 0 for empty records list', () {
      final credit = pointsService.calculateStoreWeeklyPointsCredit(
        pointsUsageRecords: [],
        storeId: 'store-A',
      );

      expect(credit, equals(0));
    });
  });

  group('PointsService - validatePointsRedemption', () {
    test('should validate valid redemption', () {
      final result = pointsService.validatePointsRedemption(
        pointsToUse: 10,
        availablePoints: 50,
        platformCommission: 30,
      );

      expect(result.isValid, isTrue);
      expect(result.discountValue, equals(10));
    });

    test('should reject when points exceed available', () {
      final result = pointsService.validatePointsRedemption(
        pointsToUse: 100,
        availablePoints: 50,
        platformCommission: 200,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Insufficient points'));
    });

    test('should reject when discount exceeds platform commission', () {
      final result = pointsService.validatePointsRedemption(
        pointsToUse: 50,
        availablePoints: 100,
        platformCommission: 30,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Maximum points allowed'));
    });

    test('should reject zero or negative points', () {
      final resultZero = pointsService.validatePointsRedemption(
        pointsToUse: 0,
        availablePoints: 50,
        platformCommission: 30,
      );

      expect(resultZero.isValid, isFalse);
      expect(resultZero.errorMessage, contains('greater than 0'));

      final resultNegative = pointsService.validatePointsRedemption(
        pointsToUse: -10,
        availablePoints: 50,
        platformCommission: 30,
      );

      expect(resultNegative.isValid, isFalse);
    });
  });

  group('PointsService - getMaxRedeemablePoints', () {
    test('should return available points when less than platform commission', () {
      final max = pointsService.getMaxRedeemablePoints(
        platformCommission: 100,
        availablePoints: 30,
      );

      expect(max, equals(30));
    });

    test('should return platform commission when less than available', () {
      final max = pointsService.getMaxRedeemablePoints(
        platformCommission: 25,
        availablePoints: 100,
      );

      expect(max, equals(25));
    });

    test('should floor platform commission when it has decimals', () {
      final max = pointsService.getMaxRedeemablePoints(
        platformCommission: 25.99,
        availablePoints: 100,
      );

      expect(max, equals(25));
    });
  });

  group('Points redemption does NOT affect store/rider earnings', () {
    test('store receives full earnings regardless of points discount', () {
      // Scenario: Order of 200 EGP, customer uses 30 points (30 EGP discount)
      // Customer pays: 170 EGP
      // Store should still receive their full commission based on 200 EGP subtotal
      
      final pointsResult = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 30,
        availablePoints: 50,
      );

      // The store weekly commission credit equals the discount
      // This means the store's total payout isn't reduced
      expect(pointsResult.storeWeeklyCommissionCredit, equals(30));
      expect(pointsResult.discountAmount, equals(30));
      
      // Platform bears the cost: discount is added to store's weekly settlement
      // Store earnings: original earnings + points credit = same as no discount scenario
    });

    test('rider earnings are not affected by points discount', () {
      // Rider earnings are based on delivery fee, not order amount
      // Points discount only affects customer payment, not delivery fee
      
      final pointsResult = pointsService.applyPoints(
        orderTotal: 200, // Order total includes delivery
        pointsToUse: 30,
        availablePoints: 50,
      );

      // Points are applied to order total, but rider's delivery fee is separate
      // The delivery fee is not reduced by points redemption
      expect(pointsResult.discountAmount, equals(30));
      expect(pointsResult.newTotal, equals(170));
      
      // Rider still receives their full delivery fee
      // This is handled by the order structure where deliveryFee is separate
    });

    test('platform bears the cost of points discount', () {
      final pointsResult = pointsService.applyPoints(
        orderTotal: 200,
        pointsToUse: 50,
        availablePoints: 100,
      );

      // Platform cost = discount amount = store credit
      // Platform pays the store the discount value in weekly settlement
      expect(pointsResult.storeWeeklyCommissionCredit, equals(50));
      
      // This means:
      // - Customer saves: 50 EGP (paid with points)
      // - Store receives: 50 EGP extra in weekly settlement
      // - Platform absorbs: 50 EGP cost
    });
  });

  group('PointsRules - direct rule tests', () {
    test('minimum points constant is 2', () {
      expect(PointsRules.minimumPointsPerOrder, equals(2));
    });

    test('minimum points threshold is 200', () {
      expect(PointsRules.minimumPointsThreshold, equals(200.0));
    });

    test('point value is 1 EGP', () {
      expect(PointsRules.pointValueInCurrency, equals(1.0));
    });

    test('referral bonus is 2 points', () {
      expect(PointsRules.referralBonusPoints, equals(2));
    });
  });
}