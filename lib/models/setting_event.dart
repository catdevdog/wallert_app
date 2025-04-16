// lib/models/setting_event.dart

class SettingEvent {
  final int id;
  final String brandName;
  final String nameKr;
  final String type;
  final String wallName;
  final DateTime date;
  final String? description;

  SettingEvent({
    required this.id,
    required this.brandName,
    required this.nameKr,
    required this.type,
    required this.wallName,
    required this.date,
    this.description,
  });

  factory SettingEvent.fromJson(Map<String, dynamic> json) {
    return SettingEvent(
      id: json['id'],
      brandName: json['brand_name'],
      nameKr: json['name_kr'],
      type: json['type'],
      wallName: json['wall_name'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_name': brandName,
      'name_kr': nameKr,
      'type': type,
      'wall_name': wallName,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
    };
  }
}