class User {
  String email;
  String userName;
  String fullname;
  String gender;
  String plan;
  String expirydate;

  User(
       {this.email,
        this.userName,
        this.gender,
        this.fullname,
        this.expirydate,
        this.plan});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonUser = new Map<String, dynamic>();
    print(this.fullname);
    jsonUser['username'] = this.userName;
    jsonUser['email'] = this.email;
    jsonUser['gender'] = this.gender;
    jsonUser['fullname'] = this.fullname;
    return jsonUser;
  }
}
