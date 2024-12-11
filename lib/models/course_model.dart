class Course {
  final String name;
  final String link;
  final String description;
  final int lessonsCount;
  final bool free;
  final String cover;

  Course({
    required this.name,
    required this.description,
    required this.link,
    required this.lessonsCount,
    required this.free,
    required this.cover,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'],
      description: json['description'],
      link: "https://${json['course_content_url']}",
      lessonsCount: json['lessons_count'],
      free: json['free'],
      cover: json['cover'],
    );
  }
}
