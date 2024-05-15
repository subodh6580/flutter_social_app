class APIMetaData {
  int totalCount;
  int pageCount;
  int currentPage;
  int perPage;

  APIMetaData({
    required this.totalCount,
    required this.pageCount,
    required this.currentPage,
    required this.perPage,
  });

  factory APIMetaData.fromJson(Map<String, dynamic> json) =>
      APIMetaData(
        totalCount: json["totalCount"] ,
        pageCount: json["pageCount"] ,
        currentPage: json["currentPage"] ,
        perPage: json["perPage"] = 20,
      );

}
