import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_profile_screen.dart';
import '../../../core/constants.dart';
import '../../chat_group/screens/group_chat.dart';
import '../components/member_group_inside.dart';

class GroupInsideScreen extends StatelessWidget {
  static String groupInsideScreenKey = '/GroupInsideScreen';

  String userName = 'Radwa';
  String lastLocatin = 'Just arrived home';
  String distance = '2.5km';

  final LatLng _initialPosition =
      const LatLng(30.0444, 31.2357); // Cairo, Egypt

  @override
  Widget build(BuildContext context) {
    final String name = ModalRoute.of(context)!.settings.arguments as String;

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
                      // const Center(
                      //   child: Icon(
                      //     Icons.horizontal_rule,
                      //     color: Colors.grey,
                      //     size: 30,
                      //   ),

                      // ),
                      SizedBox(
                        height: 30.h,
                      ),
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
                                  hintStyle: TextStyle(
                                      color: Colors.grey.withOpacity(0.8)),
                                  suffixIcon: const Icon(Icons.search,
                                      color: kPrimaryColor1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.5)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.8)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          InkWell(
                            onTap: () {},
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
                      MemberGroupInside(
                        userName: userName,
                        lastLocatin: lastLocatin,
                        distance: distance,
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
                    context, GroupProfileScreen.groupProfileScreenKey,
                    arguments: name);
              }),
              child: const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/group.jpg"),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, GroupChat.groupChatKey, arguments: name);
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
