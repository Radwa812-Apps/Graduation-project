import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:near_me_new_version/Features/Private_chat/Private_chat/screens/private_chat_screen.dart';
import 'package:near_me_new_version/core/services/chat_services.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants.dart';

class ChatsList extends StatefulWidget {
  final String Function(dynamic) formatTime;
  final String searchQuery;

  const ChatsList({
    Key? key,
    String Function(dynamic)? formatTime,
    this.searchQuery = '',
  }) : formatTime = formatTime ?? _defaultFormatTime,
       super(key: key);

  static String _defaultFormatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime messageTime;
    if (timestamp is Timestamp) {
      messageTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      messageTime = timestamp;
    } else {
      return '';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      messageTime.year,
      messageTime.month,
      messageTime.day,
    );

    final timeFormat = DateFormat('h:mm a');

    if (messageDate == today) {
      return timeFormat.format(messageTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('M/d/yyyy').format(messageTime);
    }
  }

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  late ChatService _chatService;
  List<Map<String, dynamic>> _recentChats = [];
  bool _isLoading = true;
  bool _migrationCompleted = false;
  Map<String, Uint8List?> _userImages = {};

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    _loadRecentChats();
    _runNameMigration();

    _chatService.streamRecentChats().listen((recentChats) {
      if (mounted) {
        setState(() {
          _recentChats = recentChats;
          _isLoading = false;
        });
      }
    });
  }

  //for loading user image
  Future<void> _loadUserImage(String uid) async {
    try {
      final image = await ProfileImageService().getDecryptedUserImage(uid);
      if (mounted) {
        setState(() {
          _userImages[uid] = image;
        });
      }
    } catch (e) {
      debugPrint('Error loading image for $uid: $e');
    }
  }

  Future<void> _runNameMigration() async {
    if (_migrationCompleted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasRunMigration = prefs.getBool('hasRunNameMigration') ?? false;

    if (!hasRunMigration) {
      try {
        await _chatService.migrateChatNames();
        await prefs.setBool('hasRunNameMigration', true);
        _migrationCompleted = true;
      } catch (e) {
        debugPrint('Name migration error: $e');
      }
    }
  }

  void _loadRecentChats() async {
    List<Map<String, dynamic>> recentChats =
        await _chatService.getRecentChats();
    recentChats.sort((a, b) {
      final timeA = a['timestamp'] as Timestamp?;
      final timeB = b['timestamp'] as Timestamp?;
      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;

      return timeB.compareTo(timeA);
    });
    for (var chat in recentChats) {
      final uid = chat['recipientId'];
      if (!_userImages.containsKey(uid)) {
        _loadUserImage(uid);
      }
    }
    if (mounted) {
      setState(() {
        _recentChats = recentChats;
        _isLoading = false;
      });
    }
  }

  String _formatDisplayName(String name) {
    if (name.contains(' ')) return name;

    if (name.isNotEmpty) {
      String formattedName = '';
      bool isUpperCase = false;

      for (int i = 0; i < name.length; i++) {
        final char = name[i];
        if (char.toUpperCase() == char && char != char.toLowerCase()) {
          if (i > 0 && !isUpperCase) {
            formattedName += ' ';
          }
          isUpperCase = true;
        } else {
          isUpperCase = false;
        }
        formattedName += char;
      }

      return formattedName
          .split(' ')
          .map(
            (word) =>
                word.isNotEmpty
                    ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                    : '',
          )
          .join(' ')
          .replaceAll(RegExp(r'[0-9]'), '')
          .trim();
    }

    return 'Unknown';
  }

  Future<void> _toggleMuteChat(String recipientId, bool isMuted) async {
    try {
      await _chatService.toggleMuteChat(recipientId, !isMuted);
      if (mounted) {
        setState(() {
          _recentChats =
              _recentChats.map((chat) {
                if (chat['recipientId'] == recipientId) {
                  return {...chat, 'isMuted': !isMuted};
                }
                return chat;
              }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMuted ? 'Notifications enabled' : 'Notifications muted',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to toggle mute: $e')));
      }
    }
  }

  Future<void> _deleteChat(String recipientId) async {
    bool deleteForBoth = false;

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Delete Chat'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Choose deletion option:'),
                      CheckboxListTile(
                        title: const Text('Delete for both users'),
                        value: deleteForBoth,
                        onChanged: (value) {
                          setDialogState(() {
                            deleteForBoth = value ?? false;
                          });
                        },
                        activeColor: kPrimaryColor1,
                      ),
                      const Text(
                        'Note: Deleting for both will remove the chat for you and the other user.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: kPrimaryColor1,
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
          ),
    );

    if (confirmDelete == true && mounted) {
      try {
        if (deleteForBoth) {
          await _chatService.deleteChatForEveryone(recipientId);
        } else {
          await _chatService.deleteChatForUser(recipientId);
        }
        if (mounted) {
          setState(() {
            _recentChats.removeWhere(
              (chat) => chat['recipientId'] == recipientId,
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                deleteForBoth
                    ? 'Chat deleted for both users'
                    : 'Chat deleted successfully for you',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete chat: $e')));
        }
      }
    }
  }

  List<Map<String, dynamic>> _filterChats(List<Map<String, dynamic>> chats) {
    if (widget.searchQuery.isEmpty) return chats;
    return chats.where((chat) {
      final displayName = _formatDisplayName(
        chat['recipientName'] ?? 'Unknown',
      );
      final lastMessage = chat['lastMessage']?.toString() ?? '';
      return displayName.toLowerCase().contains(
            widget.searchQuery.toLowerCase(),
          ) ||
          lastMessage.toLowerCase().contains(widget.searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final filteredChats = _filterChats(_recentChats);

    return filteredChats.isEmpty
        ? Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Image.asset(
            'assets/images/noChats.png',
            width: screenWidth * .8.w,
            height: screenHeight * .8.h,
          ),
        )
        : ListView.builder(
          padding: EdgeInsets.only(bottom: 20.h),
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            final isMuted = chat['isMuted'] ?? false;
            final displayName = _formatDisplayName(
              chat['recipientName'] ?? 'Unknown',
            );

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PrivateChatScreen(
                              recipientId: chat['recipientId'] ?? '',
                              recipientName: displayName,
                              recipientImage: chat['recipientImage'],
                            ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              _userImages[chat['recipientId']] != null
                                  ? MemoryImage(
                                    _userImages[chat['recipientId']]!,
                                  )
                                  : AssetImage('assets/images/user.jpg')
                                      as ImageProvider,
                        ),

                        SizedBox(width: 12.w),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat['lastMessage'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                    if (chat['unreadCount'] != null &&
                                        chat['unreadCount'] > 0)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor1,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          chat['unreadCount'].toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isMuted
                                        ? Icons.notifications_off_outlined
                                        : Icons.notifications_outlined,
                                    color:
                                        isMuted ? Colors.grey : kPrimaryColor1,
                                    size: 20.sp,
                                  ),
                                  onPressed:
                                      () => _toggleMuteChat(
                                        chat['recipientId'],
                                        isMuted,
                                      ),
                                  padding: EdgeInsets.zero,
                                ),
                                SizedBox(width: 4.w),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20.sp,
                                  ),
                                  onPressed:
                                      () => _deleteChat(chat['recipientId']),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            Text(
                              widget.formatTime(chat['timestamp']),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }
}
