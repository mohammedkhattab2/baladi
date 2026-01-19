/// Wallet entity in the Baladi application.
/// 
/// This is a pure domain entity representing a financial wallet
/// for stores and riders to track their earnings.
/// 
/// Architecture note: Wallet is a value object that tracks
/// financial balances. It's designed for future online payment
/// integration.
library;
/// Represents a user's financial wallet.
class Wallet {
  /// Unique identifier for the wallet.
  final String id;

  /// User ID who owns this wallet.
  final String userId;

  /// Current available balance.
  final double balance;

  /// Total earnings over lifetime.
  final double totalEarnings;

  /// Total withdrawals over lifetime.
  final double totalWithdrawals;

  /// Pending balance (not yet available for withdrawal).
  final double pendingBalance;

  /// Whether the wallet is active.
  final bool isActive;

  /// When the wallet was created.
  final DateTime createdAt;

  /// When the wallet was last updated.
  final DateTime? updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    this.balance = 0,
    this.totalEarnings = 0,
    this.totalWithdrawals = 0,
    this.pendingBalance = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this wallet with the given fields replaced.
  Wallet copyWith({
    String? id,
    String? userId,
    double? balance,
    double? totalEarnings,
    double? totalWithdrawals,
    double? pendingBalance,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns the total balance (available + pending).
  double get totalBalance => balance + pendingBalance;

  /// Returns true if there's any balance available.
  bool get hasBalance => balance > 0;

  /// Returns true if there's any pending balance.
  bool get hasPendingBalance => pendingBalance > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wallet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Wallet(id: $id, balance: $balance)';
}

/// Represents a wallet transaction.
class WalletTransaction {
  /// Unique identifier for the transaction.
  final String id;

  /// Wallet ID.
  final String walletId;

  /// Type of transaction.
  final WalletTransactionType type;

  /// Amount of the transaction.
  final double amount;

  /// Balance after this transaction.
  final double balanceAfter;

  /// Reference ID (e.g., order ID, settlement ID).
  final String? referenceId;

  /// Reference type (e.g., 'order', 'settlement').
  final String? referenceType;

  /// Description of the transaction.
  final String? description;

  /// When the transaction occurred.
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.referenceId,
    this.referenceType,
    this.description,
    required this.createdAt,
  });

  /// Returns true if this is a credit transaction.
  bool get isCredit => type == WalletTransactionType.earning ||
      type == WalletTransactionType.refund ||
      type == WalletTransactionType.adjustment && amount > 0;

  /// Returns true if this is a debit transaction.
  bool get isDebit => type == WalletTransactionType.withdrawal ||
      type == WalletTransactionType.fee ||
      type == WalletTransactionType.adjustment && amount < 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WalletTransaction(id: $id, type: ${type.name}, amount: $amount)';
}

/// Types of wallet transactions.
enum WalletTransactionType {
  /// Earnings from orders/deliveries.
  earning,

  /// Withdrawal to bank account.
  withdrawal,

  /// Refund to wallet.
  refund,

  /// Platform fee deduction.
  fee,

  /// Manual adjustment by admin.
  adjustment;

  /// Returns display name for the transaction type.
  String get displayName {
    return switch (this) {
      WalletTransactionType.earning => 'Earning',
      WalletTransactionType.withdrawal => 'Withdrawal',
      WalletTransactionType.refund => 'Refund',
      WalletTransactionType.fee => 'Fee',
      WalletTransactionType.adjustment => 'Adjustment',
    };
  }
}