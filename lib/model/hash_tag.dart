class Hashtag {
  String name;
  int counter;

  Hashtag({
    required this.name,
    required this.counter,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) =>
      Hashtag(
        name: json["hashtag"] ,
        counter: json["counter"] ,
      );

}
