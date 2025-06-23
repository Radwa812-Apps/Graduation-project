import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class Geofence {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final double radius;
  final String placeName;
  final Timestamp createdAt;

  Geofence({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.placeName,
    required this.createdAt,
  });

  factory Geofence.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Geofence(
      id: data['id'],
      userId: data['userId'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      radius: data['radius'],
      placeName: data['placeName'],
      createdAt: data['createdAt'],
    );
  }
}

class SelectPlaceScreen extends StatefulWidget {
  final String groupId;
  const SelectPlaceScreen({super.key, required this.groupId});
  static const String routeName = '/SelectPlaceScreen';

  @override
  State<SelectPlaceScreen> createState() => _SelectPlaceScreenState();
}

class _SelectPlaceScreenState extends State<SelectPlaceScreen> {
  final _auth = FirebaseAuth.instance;
  final _selectedGeofences = <String>{}; // Stores selected geofence IDs
  final _temporarySelection = <String, bool>{};
  String _searchQuery = '';
  List<Geofence> _allGeofences = [];

  final _placeIcons = const [
    Icons.home,
    Icons.location_city,
    Icons.work,
    Icons.sunny,
    Icons.restaurant,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadExistingGeofences();
    await _loadUserGeofences();
  }

  Future<void> _loadExistingGeofences() async {
    final doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final geofences = List<String>.from(data['geofenceIds'] ?? []);
      setState(() {
        _selectedGeofences.addAll(geofences);
      });
    }
  }

  Future<void> _loadUserGeofences() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('userGeofences')
        .doc(userId)
        .collection('geofences')
        .get();

    final geofences = snapshot.docs.map((doc) => Geofence.fromFirestore(doc)).toList();

    setState(() {
      _allGeofences = geofences;
    });
  }

  void _toggleGeofenceSelection(String geofenceId) {
    setState(() {
      if (_selectedGeofences.contains(geofenceId)) {
        _selectedGeofences.remove(geofenceId);
      } else {
        _temporarySelection[geofenceId] = true;
      }
    });
  }

  Future<void> _addSelectedGeofences() async {
    if (_temporarySelection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No geofences selected to add')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
            'geofenceIds': FieldValue.arrayUnion(_temporarySelection.keys.toList()),
          });

      setState(() {
        _selectedGeofences.addAll(_temporarySelection.keys);
        _temporarySelection.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully added ${_temporarySelection.length} geofences')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add geofences: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeGeofenceFromGroup(String geofenceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
            'geofenceIds': FieldValue.arrayRemove([geofenceId]),
          });

      setState(() {
        _selectedGeofences.remove(geofenceId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove geofence: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 8),
            _buildActionButtons(),
            const SizedBox(height: 8),
            Expanded(child: _buildGeofencesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofencesList() {
    if (_allGeofences.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredGeofences = _filterGeofences(_allGeofences);

    if (filteredGeofences.isEmpty) {
      return const Center(child: Text("No results found"));
    }

    return ListView.builder(
      itemCount: filteredGeofences.length,
      itemBuilder: (context, index) {
        final geofence = filteredGeofences[index];
        final isInGroup = _selectedGeofences.contains(geofence.id);
        final isTemporarilySelected = _temporarySelection[geofence.id] ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: DecoratedBox(
            decoration: _placeItemDecoration(isInGroup || isTemporarilySelected),
            child: ListTile(
              leading: _buildPlaceIcon(index, isInGroup || isTemporarilySelected),
              title: Text(
                geofence.placeName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Radius: ${geofence.radius}m\n(${geofence.latitude.toStringAsFixed(4)}, ${geofence.longitude.toStringAsFixed(4)})',
              ),
              trailing: Checkbox(
                activeColor: const Color.fromARGB(255, 107, 149, 105),
                value: isInGroup || isTemporarilySelected,
                onChanged: (value) => _toggleGeofenceSelection(geofence.id),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onTap: () => _toggleGeofenceSelection(geofence.id),
            ),
          ),
        );
      },
    );
  }

  // باقي الدوال المساعدة (بنفس الطريقة مع تغيير الأسماء فقط)
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (final geofence in _allGeofences) {
                  if (!_selectedGeofences.contains(geofence.id)) {
                    _temporarySelection[geofence.id] = true;
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Select All',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: _addSelectedGeofences,
            style: ElevatedButton.styleFrom(
              backgroundColor: _temporarySelection.isNotEmpty
                  ? Colors.blue
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Add Selected',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Geofence> _filterGeofences(List<Geofence> geofences) {
    return geofences.where((geofence) {
      return geofence.placeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // باقي الدوال تبقى كما هي مع تغيير الأسماء فقط
  BoxDecoration _placeItemDecoration(bool isSelected) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(15.0),
      border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? Colors.green.withOpacity(0.5)
              : Colors.white.withOpacity(0.9),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _buildPlaceIcon(int index, bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.withOpacity(0.4),
            blurRadius: 1,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _placeIcons[index % _placeIcons.length],
        color: Colors.white,
        size: 24,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0.3,
      backgroundColor: Colors.white,
      title: const Text('Geofences', style: TextStyle(color: kFontColor)),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: kFontColor, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DecoratedBox(
        decoration: _searchBoxDecoration(),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
            suffixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  BoxDecoration _searchBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}