import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/custom_container.dart';
import 'package:near_me_new_version/core/data/bloc/custom_places/custom_places_bloc.dart';

import '../../../core/services/customplace_crud_operation.dart';
import '../../../core/messages.dart';

class CustomPlacesCrudOp extends StatefulWidget {
  const CustomPlacesCrudOp(
      {super.key, required this.searchQuery, required this.goToPlace});
  final String searchQuery;
  final Function(double, double,String) goToPlace;
  @override
  // ignore: library_private_types_in_public_api
  _CustomPlacesCrudOpState createState() => _CustomPlacesCrudOpState();
}

class _CustomPlacesCrudOpState extends State<CustomPlacesCrudOp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<List<DocumentSnapshot>> _usersStream;

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
        var customPlaceDoc = await FirebaseFirestore.instance
            .collection('customPlaces')
            .doc(customPlaceId)
            .get();
        customPlacesDocs.add(customPlaceDoc);
      }
      return customPlacesDocs;
    });
  }

  void _showEditDialog(
      BuildContext context, String documentId, String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return Stack(children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Edit Name"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Enter new name"),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      String newName = controller.text;
                      if (newName.isNotEmpty) {
                        updateUser(documentId, newName);
                        Navigator.pop(context);
                        setState(() {
                          _usersStream = _getUserCustomPlaces();
                        });
                        AppMessages().sendVerification(
                            (context),
                            Colors.green.withOpacity(0.8),
                            'Custom place updated successfully!');
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]);
      },
    );
  }

  void _confirmDelete(BuildContext context, String documentId, String name,
      Function() onpress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: onpress,
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomPlacesBloc, CustomPlacesState>(
      listener: (context, state) {
        if (state is DeleteCustomPlacesSuccess) {
          Navigator.pop(context);
          setState(() {
            _usersStream = _getUserCustomPlaces();
          });
          AppMessages().sendVerification(
              (context),
              Colors.green.withOpacity(0.8),
              'Custom place deleted successfully!');
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Something went wrong: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("No custom places found"));
                }


                
                final filteredDate = snapshot.data!.where(((element) {
                  final data = element.data() as Map<String, dynamic>?;

                  if (data == null) return false;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  return name.contains(widget.searchQuery.toLowerCase());
                })).toList();

                if (filteredDate.isEmpty) {
                  return const Center(child: Text("No results found"));
                }
                return ListView(
                  shrinkWrap: true,
                  children: filteredDate.map((DocumentSnapshot document) {
                    final data = document.data() as Map<String, dynamic>;
                    String documentId = document.id;

                    return GestureDetector(
                      onTap: () {
                        final double latitude = data['latitude'];
                        final double longitude = data['longitude'];
                        widget.goToPlace(latitude, longitude,documentId);
                        Navigator.pop(context);
                      },
                      child: CustomContainer(
                        w: 70,
                        h: 60,
                        child: ListTile(
                          title: Text(data['name'] ?? 'No Name'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomContainer(
                                w: 40,
                                h: 40,
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showEditDialog(
                                        context, documentId, data['name']);
                                    print("Edit pressed for ${data['name']}");
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              CustomContainer(
                                w: 40,
                                h: 40,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(
                                        context, documentId, data['name'], (() {
                                      BlocProvider.of<CustomPlacesBloc>(context)
                                          .add(DeleteCustomPlace(documentId));
                                      Navigator.pop(context);
                                      setState(() {
                                        _usersStream = _getUserCustomPlaces();
                                      });
                                      AppMessages().sendVerification(
                                          (context),
                                          Colors.green.withOpacity(0.8),
                                          'Custom place deleted successfully!');
                                    }));
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
