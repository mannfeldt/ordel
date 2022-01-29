class User {
  final String uid;
  final String name;

  User(this.uid, this.name);

  factory User.fromJson(dynamic json) {
    return User(json['uid'], json['name']);
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
    };
  }
}
