import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Screens/map1.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import '../../../core/constants.dart';

class SelectPlaceScreen extends StatefulWidget {
  const SelectPlaceScreen({super.key});
  static String selectPlaceScreenKey = '/SelectPlaceScreen';
  @override
  _SelectPlaceScreenState createState() => _SelectPlaceScreenState();
}

class _SelectPlaceScreenState extends State<SelectPlaceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<List<DocumentSnapshot>> _usersStream;
  final Map<String, bool> _selectedItems = {};
  String _searchQuery = '';
  final List<IconData> _orderedTypes = [
    Icons.home,
    Icons.location_city,
    Icons.work,
    Icons.sunny,
    Icons.restaurant,
  ];
  IconData _getIconForIndex(int index) {
    if (index >= 0 && index < _orderedTypes.length) {
      return _orderedTypes[index];
    }
    return Icons.place;
  }

  @override
  void initState() {
    super.initState();
    _usersStream = _getUserCustomPlaces();
  }

  Stream<List<DocumentSnapshot>> _getUserCustomPlaces() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('user_customPlaces')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((userPlacesSnapshot) async {
          List<DocumentSnapshot> customPlacesDocs = [];
          for (var userPlaceDoc in userPlacesSnapshot.docs) {
            var customPlaceId = userPlaceDoc['customPlaceId'];
            var customPlaceDoc =
                await FirebaseFirestore.instance
                    .collection('customPlaces')
                    .doc(customPlaceId)
                    .get();
            customPlacesDocs.add(customPlaceDoc);
          }
          return customPlacesDocs;
        });
  }

  @override
  Widget build(BuildContext context) {
    int s = 0;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        backgroundColor: Colors.white,
        title: const Text('Custom Places', style: TextStyle(color: kFontColor)),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.5, top: 7, bottom: 7),
          child: CustomBackButton(
            icon: Icons.arrow_back_ios_outlined,
            ontap: () => Navigator.pop(context),
          ),
        ),
        //IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back_ios,
        //     color: kFontColor,
        //     size: 28,
        //   ),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _usersStream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.isEmpty) {
                    return const Center(child: Text("No custom places found"));
                  }

                  final filteredData =
                      snapshot.data!.where((element) {
                        final data = element.data() as Map<String, dynamic>?;
                        if (data == null) return false;
                        final name =
                            data['name']?.toString().toLowerCase() ?? '';
                        return name.contains(_searchQuery.toLowerCase());
                      }).toList();

                  if (filteredData.isEmpty) {
                    return const Center(child: Text("No results found"));
                  }

                  return ListView(
                    children:
                        filteredData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final document = entry.value;
                          final data = document.data() as Map<String, dynamic>;
                          String documentId = document.id;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _selectedItems[documentId] ?? false
                                            ? Colors.green.withOpacity(0.5)
                                            : Colors.white.withOpacity(0.9),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            _selectedItems[documentId] ?? false
                                                ? Colors.green.withOpacity(0.5)
                                                : Colors.grey.withOpacity(0.4),
                                        blurRadius: 1,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getIconForIndex(index),
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                trailing: Checkbox(
                                  activeColor: const Color.fromARGB(
                                    255,
                                    107,
                                    149,
                                    105,
                                  ),
                                  value: _selectedItems[documentId] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _selectedItems[documentId] = value!;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                title: Text(
                                  data['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 250, bottom: 25),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Map1.map1Key, arguments: "SelectPlaceScreen");
                },
                child: Container(
                  //color: kPrimaryColor1,
                  height: 60,
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: kPrimaryColor1,
                  ),
                  child: Center(
                    child: Text(
                      "Add place",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
