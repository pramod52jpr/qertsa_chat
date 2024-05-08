class Chat {
  String? id;
  String? sender;
  String? receiver;
  String? type;
  String? message;
  String? date;

  Chat(
      {this.id,
        this.sender,
        this.receiver,
        this.type,
        this.message,
        this.date});

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender = json['sender'];
    receiver = json['receiver'];
    type = json['type'];
    message = json['message'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['type'] = type;
    data['message'] = message;
    data['date'] = date;
    return data;
  }
}
