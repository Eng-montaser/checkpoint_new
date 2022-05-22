class MessageModal {
  int? id;
  String? body;
  int? read;
  String? path;
  int? type;
  int? userId;
  String? sender_name;
  int? conversationId;
  String? createdAt;

  MessageModal({
    this.id,
    this.body,
    this.read,
    this.path,
    this.type,
    this.userId,
    this.sender_name,
    this.conversationId,
    this.createdAt,
  });

  MessageModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    body = "${json['body'].toString()}";
    path = json['type'] != 0 ? json['path'] : '';
    type = int.parse('${json['type'].toString()}');
    read = json['read'] == false ? 0 : 1;
    userId = json['user_id'];
    sender_name = json['sender_name'] != null ? json['sender_name'] : '';
    conversationId = json['conversation_id'];
    createdAt = json['created_at'];
    //updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['body'] = this.body;
    data['read'] = this.read;
    data['path'] = this.path;
    data['type'] = this.type;
    data['user_id'] = this.userId;
    data['sender_name'] = this.sender_name;
    data['conversation_id'] = this.conversationId;
    data['created_at'] = this.createdAt;
    return data;
  }
}
