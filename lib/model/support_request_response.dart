class SupportRequestsResponse {
  SupportRequest? supportRequest;

  SupportRequestsResponse({supportRequest});

  SupportRequestsResponse.fromJson(Map<String, dynamic> json) {
    supportRequest = json['supportRequest'] != null
        ? SupportRequest.fromJson(json['supportRequest'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (supportRequest != null) {
      data['supportRequest'] = supportRequest!.toJson();
    }
    return data;
  }
}

class SupportRequest {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? phone;
  String? requestMessage;
  String? replyMessage;
  int? isReply;
  int? status;
  int? createdAt;
  int? createdBy;
  int? updatedAt;
  int? updatedBy;

  SupportRequest(
      {id,
      userId,
      name,
      email,
      phone,
      requestMessage,
      replyMessage,
      isReply,
      status,
      createdAt,
      createdBy,
      updatedAt,
      updatedBy});

  SupportRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    requestMessage = json['request_message'];
    replyMessage = json['reply_message'];
    isReply = json['is_reply'];
    status = json['status'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['request_message'] = requestMessage;
    data['reply_message'] = replyMessage;
    data['is_reply'] = isReply;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    data['updated_at'] = updatedAt;
    data['updated_by'] = updatedBy;
    return data;
  }
}

class Links {
  Self? self;
  Self? first;
  Self? last;

  Links({self, first, last});

  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'] != null ? Self.fromJson(json['self']) : null;
    first = json['first'] != null ? Self.fromJson(json['first']) : null;
    last = json['last'] != null ? Self.fromJson(json['last']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (self != null) {
      data['self'] = self!.toJson();
    }
    if (first != null) {
      data['first'] = first!.toJson();
    }
    if (last != null) {
      data['last'] = last!.toJson();
    }
    return data;
  }
}

class Self {
  String? href;

  Self({href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    return data;
  }
}

class Meta {
  int? totalCount;
  int? pageCount;
  int? currentPage;
  int? perPage;

  Meta({totalCount, pageCount, currentPage, perPage});

  Meta.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    pageCount = json['pageCount'];
    currentPage = json['currentPage'];
    perPage = json['perPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    data['pageCount'] = pageCount;
    data['currentPage'] = currentPage;
    data['perPage'] = perPage;
    return data;
  }
}
