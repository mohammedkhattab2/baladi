// Domain - Vehicle type enumeration.
//
// Defines the vehicle types available for delivery riders.
// Maps to the `vehicle_type` column in the riders table.

/// The type of vehicle a rider uses for deliveries.
enum VehicleType {
  /// Human-powered bicycle.
  bicycle('bicycle', 'دراجة هوائية'),

  /// Motorized motorcycle or scooter.
  motorcycle('motorcycle', 'موتوسيكل'),

  /// Four-wheeled car.
  car('car', 'سيارة');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const VehicleType(this.value, this.labelAr);

  /// Creates a [VehicleType] from its backend string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any type.
  static VehicleType fromValue(String value) {
    return VehicleType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown VehicleType: $value'),
    );
  }
}