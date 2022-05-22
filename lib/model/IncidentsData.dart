import 'dart:io';

class IncidentsData {
  String description;
  List<File> photos;
  String name;
  IncidentsData(
      {required this.description, required this.photos, required this.name});
  getBody() {
    return {"description": description, "photos": photos, "name": name};
  }
}
