class PollsModel {
  int? id;
  String? title;
  int? totalVoteCount;
  int? isVote;

  List<PollOption>? pollOptions;

  PollsModel(
      {this.id,
        this.title,
        this.totalVoteCount,
        this.isVote,
        this.pollOptions});

  PollsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    totalVoteCount = json['total_vote_count'];
    isVote = json['is_vote'];

    if (json['pollOptions'] != null) {
      pollOptions = <PollOption>[];
      json['pollOptions'].forEach((v) {
        pollOptions!.add(PollOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['total_vote_count'] = totalVoteCount;
    data['is_vote'] = isVote;

    if (pollOptions != null) {
      data['pollQuestionOption'] = pollOptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PollOption {
  int? id;
  String? title;
  int? totalOptionVoteCount;

  PollOption({this.id, this.title, this.totalOptionVoteCount});

  PollOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    totalOptionVoteCount = json['total_option_vote_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['total_option_vote_count'] = totalOptionVoteCount;
    return data;
  }
}
