class Itopics {
  int tid;
  String tname;
  String ticon;
  String did;

  Itopics({this.tid, this.tname, this.ticon, this.did});

  Itopics.fromJson(Map<String, dynamic> json) {
    tid = json['tid'];
    tname = json['tname'];
    ticon = json['ticon'];
    did = json['did'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tid'] = this.tid;
    data['tname'] = this.tname;
    data['ticon'] = this.ticon;
    data['did'] = this.did;
    return data;
  }
}