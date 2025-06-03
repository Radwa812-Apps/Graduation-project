import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_profile_screen.dart';
import '../../../core/constants.dart';
import '../../chat_group/screens/group_chat.dart';
import '../components/member_group_inside.dart';
import 'package:near_me_new_version/core/services/group_services.dart';

class GroupInsideScreen extends StatefulWidget {
  static String groupInsideScreenKey = '/GroupInsideScreen';

  const GroupInsideScreen({super.key});

  @override
  _GroupInsideScreenState createState() => _GroupInsideScreenState();
}

class _GroupInsideScreenState extends State<GroupInsideScreen> {
  final GroupService _groupService = GroupService();
  List<Map<String, dynamic>> _members = [];
  String? _groupName;
  String? _createdBy;
  String? _groupId; 
  bool _isDataLoaded = false;

  final LatLng _initialPosition = const LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadGroupData();
      _isDataLoaded = true;
    }
  }

  void _loadGroupData() async {
    final String? groupId = ModalRoute.of(context)?.settings.arguments as String?;
    print("Group ID received: $groupId");

    if (groupId != null) {
      final group = await _groupService.getGroupById(groupId);
      print("Group data: ${group?.toJson()}");

      if (group != null) {
        print("Members in group: ${group.members}");
        List<Map<String, dynamic>> membersData = [];
        for (String uid in group.members) {
          Map<String, String>? userData = await _groupService.getUserData(uid);
          print("User data for UID $uid: $userData");
          if (userData != null) {
            membersData.add({
              'uid': uid,
              'userName': "${userData['fName']} ${userData['lName']}".trim(),
              'lastLocation': 'Just arrived home',
              'distance': '2.5km',
            });
          }
        }
        setState(() {
          _members = membersData;
          _groupName = group.name;
          _createdBy = group.createdBy;
          _groupId = groupId; 
          print("Members list updated: $_members");
        });
      } else {
        print("Group not found for ID: $groupId");
      }
    } else {
      print("No groupId provided!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('group_location'),
                position: _initialPosition,
                infoWindow: const InfoWindow(title: 'Group Location'),
              ),
            },
          ),
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: DraggableScrollableSheet(
              initialChildSize: 0.53,
              minChildSize: 0.1,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, -5),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      SizedBox(height: 30.h),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                  suffixIcon: const Icon(Icons.search, color: kPrimaryColor1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          InkWell(
                            onTap: () {
                              //HERE
                              
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: kPrimaryColor1,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!_isDataLoaded)
                        const Center(child: CircularProgressIndicator())
                      else if (_members.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "No members in this group.",
                            style: TextStyle(color: kFontColor),
                          ),
                        )
                      else
                        ..._members.map(
                          (member) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: MemberGroupInside(
                              userName: member['userName'],
                              lastLocatin: member['lastLocation'],
                              distance: member['distance'],
                              isOwner: member['uid'] == _createdBy,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          CustomBackButton(
            icon: Icons.arrow_back_ios_outlined,
            ontap: () {
              Navigator.pop(context);
            },
          ),
          Positioned(
            bottom: 343.h,
            left: MediaQuery.of(context).size.width / 2 - 40.sp,
            child: GestureDetector(
              onTap: (() {
                Navigator.pushNamed(
                  context,
                  GroupProfileScreen.groupProfileScreenKey,
                  arguments: _groupId, 
                );
              }),
              child: const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/group.jpg"),
              ),
            ),
          ),
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            GroupChat.groupChatKey,
            arguments: _groupName ?? '',
          );
        },
        backgroundColor: kPrimaryColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: const Icon(Icons.message, color: Colors.white),
      ),*/
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    if (_groupId != null && _groupName != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChat(
            groupId: _groupId!,
            groupName: _groupName!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group data not loaded yet')),
      );
    }
  },
  backgroundColor: kPrimaryColor1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50.0),
  ),
  child: const Icon(Icons.message, color: Colors.white),
),
    );
  }
}