/// [SimInfo] is a class that encapsulates information about a SIM card.
/// The [SimInfo] class provides a factory constructor `fromJson` to create an instance from a JSON object.
/// This is particularly useful when parsing JSON data received from an API.
///
/// The `toString` method is overridden to provide a string representation of the `SimInfo` object.
/// This can be useful for debugging purposes.
///
/// The `==` operator is overridden to provide value equality. Two `SimInfo` objects are considered equal if all their properties are equal.
///
/// The `hashCode` getter is overridden to provide a hash code that is consistent with the `==` operator.
/// This is important if you intend to use `SimInfo` objects as keys in a `Map` or insert them into a `Set`.

class SimInfo {
  /// [carrierName] : The name of the carrier.
  final String carrierName;

  /// - displayName : The display name of the carrier.
  final String displayName;

  ///  [slotIndex] : The index of the SIM card slot.
  final String slotIndex;

  /// - [number] : The phone number associated with the SIM card.
  final String number;

  /// - [countryIso] : The ISO country code associated with the SIM card.
  final String countryIso;

  /// - [countryPhonePrefix] : The phone prefix for the country of the SIM card.
  final String countryPhonePrefix;

  SimInfo({
    required this.carrierName,
    required this.displayName,
    required this.slotIndex,
    required this.number,
    required this.countryIso,
    required this.countryPhonePrefix,
  });

  SimInfo copyWith({
    String? carrierName,
    String? displayName,
    String? slotIndex,
    String? number,
    String? countryIso,
    String? countryPhonePrefix,
  }) {
    return SimInfo(
      carrierName: carrierName ?? this.carrierName,
      displayName: displayName ?? this.displayName,
      slotIndex: slotIndex ?? this.slotIndex,
      number: number ?? this.number,
      countryIso: countryIso ?? this.countryIso,
      countryPhonePrefix: countryPhonePrefix ?? this.countryPhonePrefix,
    );
  }

  factory SimInfo.fromJson(Map<String, dynamic> json) {
    return SimInfo(
      carrierName: json['carrierName'],
      displayName: json['displayName'],
      slotIndex: json['slotIndex'].toString(),
      number: json['number'],
      countryIso: json['countryIso'],
      countryPhonePrefix: json['countryPhonePrefix'],
    );
  }

  @override
  String toString() {
    return 'SimInfo{carrierName: $carrierName, displayName: $displayName, slotIndex: $slotIndex, number: $number, countryIso: $countryIso, countryPhonePrefix: $countryPhonePrefix}\n';
  }

  Map<String, dynamic> toJson() {
    return {
      'carrierName': carrierName,
      'displayName': displayName,
      'slotIndex': slotIndex,
      'number': number,
      'countryIso': countryIso,
      'countryPhonePrefix': countryPhonePrefix,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is SimInfo &&
      runtimeType == other.runtimeType &&
      carrierName == other.carrierName &&
      displayName == other.displayName &&
      slotIndex == other.slotIndex &&
      number == other.number &&
      countryIso == other.countryIso &&
      countryPhonePrefix == other.countryPhonePrefix;

  @override
  int get hashCode =>
      carrierName.hashCode ^
      displayName.hashCode ^
      slotIndex.hashCode ^
      number.hashCode ^
      countryIso.hashCode ^
      countryPhonePrefix.hashCode;
}
