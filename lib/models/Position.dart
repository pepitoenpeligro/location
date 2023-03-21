class PositionInterface {
  int? timestamp;
  double? latitude;
  double? longitude;

  @override
  String toString() {
    return toJson().toString();
  }

  Map toJson() =>
      {'timestamp': timestamp, 'latitude': latitude, 'longitude': longitude};
}
