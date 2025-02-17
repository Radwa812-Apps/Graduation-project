import 'package:flutter/material.dart';
import 'custom_container.dart';

class CustomPlaceItem extends StatelessWidget {
  const CustomPlaceItem({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: CustomContainer(
        w: 60,
        h: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            CustomContainer(
              w: 40,
              h: 40,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10),
            CustomContainer(
              w: 40,
              h: 40,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // services.deleteCustomPlace(customPlaces.id);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
