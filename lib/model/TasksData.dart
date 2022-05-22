class TasksData {
  int id;
  DateTime created_at;
  String description;
  String? notes;
  TasksStatus taskStatus;

  TasksData({
    required this.id,
    required this.created_at,
    this.notes,
    required this.taskStatus,
    required this.description,
  });
  factory TasksData.fromJson(Map<String, dynamic> json) {
    late TasksStatus taskStatus;
    switch (json['status']) {
      case "pending":
        taskStatus = TasksStatus.pending;
        break;
      case "done":
        taskStatus = TasksStatus.done;
        break;
      case "rejected":
        taskStatus = TasksStatus.rejected;
        break;
      case "received":
        taskStatus = TasksStatus.received;
        break;
    }
    return TasksData(
        id: json['id'],
        created_at: DateTime.parse(json['created_at']),
        description: json['description'],
        notes: json['notes'],
        taskStatus: taskStatus

//    taskStatus=json['notes'];
        );
  }
}

enum TasksStatus { pending, done, rejected, received }
