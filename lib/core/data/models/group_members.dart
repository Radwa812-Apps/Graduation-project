
class GroupMembers {
  final String id;
  final String groupId;
  final String userId;
  final String roleInGroup;
  final DateTime joinAt;

  GroupMembers(
      {required this.id,
      required this.groupId,
      required this.userId,
      required this.roleInGroup,
      required this.joinAt});

  factory GroupMembers.fromJson(Map<String, dynamic> json, String id) {
    return GroupMembers(
        id: id,
        groupId: json['groupId'],
        userId: json['userId'],
        roleInGroup: json['roleInGroup'],
        joinAt: DateTime.parse(json['joinAt']));
  }
}
