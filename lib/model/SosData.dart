class SosData {
  String? long;
  String? lat;
  int? message_id;
  String? message_text;
  SosData({this.long, this.lat, this.message_id, this.message_text});
  getBody() {
    return {
      "lat": lat,
      "long": long,
      "action_id": '${message_id}',
      "action_text": message_text
    };
  }
}

class Action_Messages {
  int id;
  String message;
  Action_Messages({required this.id, required this.message});
  getBody() {
    return {"action_id": '${id}', "action_text": message};
  }
}

class IsStartData {
  bool is_start;
  String? start_time;
  String? tour_status;
  String? tour_time;
  IsStartData(
      {required this.is_start,
      this.start_time,
      this.tour_status,
      this.tour_time});
  factory IsStartData.fromJson(Map<String, dynamic> json) => IsStartData(
      is_start: json['data'],
      start_time: json['start_time'],
      tour_status: json['tour_status'],
      tour_time: json['tour_time']);
}
