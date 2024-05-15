class CountryModel {
  int id = 0;
  String name = '';
  String iso3 = '';
  String iso2 = '';
  String phoneCode = '';
  String capital = '';
  String currency = '';

  CountryModel();

  factory CountryModel.fromJson(dynamic json) {
    CountryModel model = CountryModel();
    model.id = json['id'];
    model.name = json['name'];
    model.iso3 = json['iso3'];
    model.iso2 = json['iso2'];
    model.phoneCode = json['phone_code'];
    model.capital = json['capital'];
    model.currency = json['currency'];

    return model;
  }
}
