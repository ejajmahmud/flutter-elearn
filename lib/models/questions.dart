class Question {
  String qanswer;
  String qdifficulty;
  String qquestions;
  int qtopicid;

  Question({this.qanswer, this.qdifficulty, this.qquestions, this.qtopicid});

  Question.fromJson(Map<String, dynamic> json) {
    qanswer = json['qanswer'];
    qdifficulty = json['qdifficulty'];
    qquestions = json['qquestions'];
    qtopicid = json['qtopicid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['qanswer'] = this.qanswer;
    data['qdifficulty'] = this.qdifficulty;
    data['qquestions'] = this.qquestions;
    data['qtopicid'] = this.qtopicid;
    return data;
  }
}