class LocationModel {
  double latitude;
  double longitude;
  String name;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        latitude: json["latitude"],
        longitude: json["longitude"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'name': name,
  };
}
