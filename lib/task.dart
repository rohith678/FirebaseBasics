class Task {
  String id;
  String title;
  String description;
  
  Task({required this.id, required this.title, required this.description});

  toJson() {
    return {"id": id, "title": title, "description": description};
  }

  static fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['id'], title: json['title'], description: json['description']);
  }
}
