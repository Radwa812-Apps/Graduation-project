class Notification {
  final String id;
  final String chatMessageId;
  final String riskGroupId;
  final String userLocationId;
  final String groupCustomPlacesId;
  final String type; // (custom,risk,chat)
  final String messageLocation;
  final bool isRead;

  Notification(
      {required this.id,
      required this.chatMessageId,
      required this.riskGroupId,
      required this.userLocationId,
      required this.groupCustomPlacesId,
      required this.type,
      required this.messageLocation,
      required this.isRead});

  factory Notification.fromJson(Map<String, dynamic> json, String id) {
    return Notification(
        id: id,
        chatMessageId: json['chatMessageId'],
        riskGroupId: json['riskGrouptId'],
        userLocationId: json['userLocationId'],
        groupCustomPlacesId: json['groupCustomPlacesId'],
        type: json['type'],
        messageLocation: json['messageLocation'],
        isRead: json['isRead']);
  }
}
