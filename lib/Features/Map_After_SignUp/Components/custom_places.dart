
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/custom_container.dart';
import 'package:near_me_new_version/core/services/geofence_in_map.dart';
class GeofencesCrudOp extends StatefulWidget {
  const GeofencesCrudOp({
    super.key,
    required this.searchQuery,
    required this.goToPlace,
  });
  final String searchQuery;
  final Function(double, double, String) goToPlace;

  @override
  _GeofencesCrudOpState createState() => _GeofencesCrudOpState();
}

class _GeofencesCrudOpState extends State<GeofencesCrudOp> {
  late Stream<QuerySnapshot> _geofencesStream;

  @override
  void initState() {
    super.initState();
    _geofencesStream = getUserGeofences();
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: StreamBuilder<QuerySnapshot>(
          stream: _geofencesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No geofences found"));
            }

            final filteredData =
                snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      data['placeName']?.toString().toLowerCase() ?? '';
                  return name.contains(widget.searchQuery.toLowerCase());
                }).toList();

            if (filteredData.isEmpty) {
              return const Center(child: Text("No results found"));
            }

            return ListView(
              shrinkWrap: true,
              children:
                  filteredData.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        widget.goToPlace(
                          data['latitude'],
                          data['longitude'],
                          doc.id,
                        );
                        Navigator.pop(context);
                      },
                      child: CustomContainer(
                        w: 70,
                        h: 80,
                        child: ListTile(
                          title: Text(data['placeName'] ?? 'Unnamed Geofence'),
                          subtitle: Text(
                            'Radius: ${data['radius']}m\n'
                            'Lat: ${data['latitude'].toStringAsFixed(4)} , '
                            'Lng: ${data['longitude'].toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomContainer(
                                w: 40,
                                h: 40,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed:(){
                                      showEditDialog(
                                        context,
                                        doc.id,
                                        data['placeName'],
                                      
                                      );
                                      print("Edit pressed for ${data['placeName']}");
                                  }
                                      
                                ),
                              ),
                              const SizedBox(width: 7),
                              CustomContainer(
                                w: 40,
                                h: 40,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => confirmDelete(context, doc.id),
                                ),
                              ),
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
  }
}
