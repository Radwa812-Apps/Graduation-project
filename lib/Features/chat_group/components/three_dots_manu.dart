import 'package:flutter/material.dart';
import '../../../core/constants.dart';
class ThreeDotMenu extends StatelessWidget {
  final VoidCallback? onMutePressed;
  final VoidCallback? onClearChatPressed;
  final VoidCallback? onSearchPressed;

  const ThreeDotMenu({
    Key? key,
    this.onMutePressed,
    this.onClearChatPressed,
    this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: kPrimaryColor1,
        size: 30,
      ),
      onSelected: (value) {
        switch (value) {
          case 'Mute':
            if (onMutePressed != null) onMutePressed!();
            break;
          case 'Clear Chat':
            if (onClearChatPressed != null) onClearChatPressed!();
            break;
          case 'Search':
            if (onSearchPressed != null) onSearchPressed!();
            break;
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: background,
      elevation: 8,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'Mute',
            child: _buildMenuItem(Icons.volume_off_outlined ,'Mute',),
          ),
          PopupMenuItem<String>(
            value: 'Clear Chat',
            child: _buildMenuItem(Icons.cleaning_services_outlined, 'Clear Chat'),
          ),
          PopupMenuItem<String>(
            value: 'Search',
            child: _buildMenuItem(Icons.search, 'Search'),
          ),
        ];
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor1, size: 20),
        SizedBox(width: 8),
        Expanded( 
          child: Text(
            text,
            style: const TextStyle(
              color:textColor,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
