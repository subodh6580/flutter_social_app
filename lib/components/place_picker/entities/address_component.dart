class AddressComponent {
  String name;
  String shortName;

  AddressComponent({required this.name, required this.shortName});

  static AddressComponent fromJson(dynamic json) {
    return AddressComponent(name: json['long_name'], shortName: json['short_name']);
  }
}
