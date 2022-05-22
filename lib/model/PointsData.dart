class PointsData {
  int id;
  DateTime created_at;
  String name;
  TaskStatus taskStatus;
  PointsData({
    required this.id,
    required this.created_at,
    required this.name,
    required this.taskStatus,
  });
  factory PointsData.fromJson(
          Map<String, dynamic> json, TaskStatus tasksStatus) =>
      PointsData(
          id: json['id'],
          created_at: DateTime.parse(json['created_at']),
          name: json['point']['name'],
          taskStatus: tasksStatus);
}

enum TaskStatus { Required, Red, Missed }
