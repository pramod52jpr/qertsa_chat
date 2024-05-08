class User {
  String? uid;
  String? phone;

  User({this.uid, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['phone'] = phone;
    return data;
  }
}
