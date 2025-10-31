class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String channelKey;
  final DateTime? scheduledDateTime;
  final bool isScheduled;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.channelKey,
    this.scheduledDateTime,
    this.isScheduled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'channelKey': channelKey,
      'scheduledDateTime': scheduledDateTime?.toIso8601String(),
      'isScheduled': isScheduled,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      channelKey: map['channelKey'],
      scheduledDateTime: map['scheduledDateTime'] != null 
          ? DateTime.parse(map['scheduledDateTime'])
          : null,
      isScheduled: map['isScheduled'] ?? false,
    );
  }
}