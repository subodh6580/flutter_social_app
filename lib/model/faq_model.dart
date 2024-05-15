

class FAQModel {
  int id;
  String question;
  String answer;

  FAQModel({
    required this.id,
    required this.question,
    required this.answer,
    // required this.subCategories,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) => FAQModel(
    id: json["id"],
    question: json["question"],
    answer: json["answer"],
  );
}




