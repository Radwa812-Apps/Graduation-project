import 'dart:async' show StreamSubscription;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/core/services/chat_services.dart'
    show ChatService;
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:record/record.dart';
import 'package:intl/intl.dart';
import '../components/chat_input_field.dart';
import '../components/group_media_screen.dart';
import '../components/message_bubble.dart';
import '../components/header_group_chat.dart';

enum MediaType { image, video, voice }

class GroupChat extends StatefulWidget {
  final String groupId;
  final String groupName;

  static const String routeName = '/group-chat';
  static String get groupChatKey => routeName;
  static Map<String, dynamic> createArguments(
    String groupId,
    String groupName,
    List<Map<String, dynamic>> messages,
  ) {
    return {'groupId': groupId, 'groupName': groupName, 'messages': messages};
  }

  const GroupChat({Key? key, required this.groupId, required this.groupName})
    : super(key: key);

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late ChatService _chatService;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _filteredMessages = [];
  bool _isSending = false;
  bool _showEmojiPicker = false;
  StreamSubscription? _messageSubscription;
  late final Record _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;

  String _searchQuery = '';
  int _currentSearchIndex = -1;
  List<int> _searchMatchIndices = [];
  DateTime? _selectedDate;
  Uint8List? _groupImage;

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    _setupMessageStream();
    _audioRecorder = Record();
    _fetchGroupImage();
    _filteredMessages = _messages;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    await _chatService.markGroupMessagesAsRead(widget.groupId);
  }

  Future<void> _fetchGroupImage() async {
    try {
      final image = await GroupService().getDecryptedGroupImage(widget.groupId);
      if (mounted) {
        setState(() {
          _groupImage = image;
        });
      }
    } catch (e) {
      print('❌ Error fetching group image: $e');
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _setupMessageStream() {
    _messageSubscription = _chatService
        .getGroupMessages(widget.groupId)
        .listen(
          (messages) {
            if (!mounted) return;
            if (_messages.isEmpty ||
                !_areMessagesEqual(_messages, messages) ||
                messages.length > _messages.length) {
              if (mounted) {
                setState(() {
                  _messages = messages;
                  _filterMessages();
                });
                _scrollToBottom();
              }
            }
          },
          onError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading messages: $error')),
              );
            }
          },
        );
  }

  bool _areMessagesEqual(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i]['id'] != b[i]['id']) return false;
      if (a[i]['text'] != b[i]['text']) return false;
      if (a[i]['imageUrl'] != b[i]['imageUrl']) return false;
      if (a[i]['videoUrl'] != b[i]['videoUrl']) return false;
      if (a[i]['voiceUrl'] != b[i]['voiceUrl']) return false;
    }
    return true;
  }

  void _filterMessages() {
    if (_searchQuery.isEmpty && _selectedDate == null) {
      _filteredMessages = _messages;
      _searchMatchIndices = [];
    } else {
      _filteredMessages =
          _messages.where((msg) {
            bool matchesSearch =
                _searchQuery.isEmpty ||
                (msg['text']?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);
            bool matchesDate =
                _selectedDate == null ||
                (msg['timestamp'] is Timestamp &&
                    DateFormat(
                          'yyyy-MM-dd',
                        ).format(msg['timestamp'].toDate()) ==
                        DateFormat('yyyy-MM-dd').format(_selectedDate!));
            return matchesSearch && matchesDate;
          }).toList();
      _searchMatchIndices = List.generate(
        _filteredMessages.length,
        (index) => _messages.indexWhere(
          (m) => m['id'] == _filteredMessages[index]['id'],
        ),
      );
    }
    setState(() {});
  }

  void _navigateSearch(bool forward) {
    if (_searchMatchIndices.isEmpty) return;
    setState(() {
      if (forward) {
        _currentSearchIndex =
            (_currentSearchIndex + 1) % _searchMatchIndices.length;
      } else {
        _currentSearchIndex =
            (_currentSearchIndex - 1) % _searchMatchIndices.length;
      }
      if (_scrollController.hasClients) {
        final index = _searchMatchIndices[_currentSearchIndex];
        final itemHeight = 100.0; // Approximate height per message
        _scrollController.animateTo(
          index * itemHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickMedia() async {
    final result = await showModalBottomSheet<MediaType>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Image'),
                  onTap: () => Navigator.pop(context, MediaType.image),
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Video'),
                  onTap: () => Navigator.pop(context, MediaType.video),
                ),
                ListTile(
                  leading: const Icon(Icons.mic),
                  title: const Text('Voice Message'),
                  onTap: () => Navigator.pop(context, MediaType.voice),
                ),
              ],
            ),
          ),
    );

    if (result == null) return;

    try {
      setState(() => _isSending = true);

      switch (result) {
        case MediaType.image:
          await _pickImage();
          break;
        case MediaType.video:
          await _pickVideo();
          break;
        case MediaType.voice:
          await _pickVoiceMessage();
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send media: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickVoiceMessage() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() => _isRecording = true);

        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.aac';

        await _audioRecorder.start(path: path, encoder: AudioEncoder.aacLc);

        setState(() => _audioPath = path);
      }
    } catch (e) {
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() => _isRecording = false);
      final path = await _audioRecorder.stop();

      if (path != null) {
        setState(() => _audioPath = path);

        final voiceUrl = await _chatService.uploadVoiceMessage(
          widget.groupId,
          path,
        );

        await _chatService.sendMessage(
          groupId: widget.groupId,
          text: 'Voice message',
          voiceUrl: voiceUrl,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
      }
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _imagePicker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final videoUrl = await _chatService.uploadVideo(
        widget.groupId,
        pickedFile.path,
      );

      await _chatService.sendMessage(
        groupId: widget.groupId,
        text: '',
        videoUrl: videoUrl,
      );
    }
  }

  Widget _buildRecordingUI() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.mic, color: Colors.red, size: 30),
            const SizedBox(width: 8),
            const Text(
              "Recording...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              child: const Text("CANCEL", style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() => _isRecording = false);
                _audioRecorder.stop().then((_) => File(_audioPath!).delete());
              },
            ),
            TextButton(
              child: const Text("SEND", style: TextStyle(color: Colors.blue)),
              onPressed: _stopRecording,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _showEmojiPicker = false;
    });

    try {
      await _chatService.sendMessage(
        groupId: widget.groupId,
        text: _messageController.text,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _isSending = true);

        final imageUrl = await _chatService.uploadImage(
          widget.groupId,
          pickedFile.path,
        );

        if (imageUrl.isNotEmpty) {
          await _chatService.sendMessage(
            groupId: widget.groupId,
            text: '',
            imageUrl: imageUrl,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      FocusScope.of(context).unfocus();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _clearChat() async {
    bool confirmDelete =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Clear Chat'),
                content: const Text(
                  'All messages will be deleted. This action cannot be undone.',
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
                    child: const Text('Continue'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmDelete && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .get()
            .then((snapshot) {
              for (DocumentSnapshot ds in snapshot.docs) {
                ds.reference.delete();
              }
            });
        if (mounted) {
          setState(() {
            _messages.clear();
            _filteredMessages.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat cleared successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to clear chat: $e')));
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentSearchIndex = -1;
      _filterMessages();
    });
  }

  void _showCalendarPicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _filterMessages();
      });
    }
  }

  String _getDateLabel(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _navigateToGroupMedia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GroupMediaScreen(
              messages: _messages,
              groupName: widget.groupName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showEmojiPicker = false),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: HeaderGroupChat(
            title: widget.groupName,
            backArrow: const Icon(
              Icons.arrow_back,
              color: kPrimaryColor1,
              size: 25,
            ),
            onBackPressed: () => Navigator.pop(context),
            showCircleAvatar: true,
            image: '', // ممكن تحذفيه لو مش مستخدم أصلاً
            circleAvatarImageBytes: _groupImage,
            onClearChatPressed: _clearChat,
            onSearchChanged: _onSearchChanged,
            onGroupInfoPressed: _navigateToGroupMedia,
          ),
        ),
        body: Column(
          children: [
            if (_searchQuery.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed:
                        _searchMatchIndices.isEmpty
                            ? null
                            : () => _navigateSearch(false),
                  ),
                  Text('${_searchMatchIndices.length} matches'),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed:
                        _searchMatchIndices.isEmpty
                            ? null
                            : () => _navigateSearch(true),
                  ),
                ],
              ),
            Expanded(
              child:
                  _filteredMessages.isEmpty
                      ? const Center(child: Text('No messages yet'))
                      : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: _filteredMessages.length,
                        itemBuilder: (context, index) {
                          final message = _filteredMessages[index];
                          final isMe =
                              message['senderId'] == _chatService.currentUserId;
                          final timestamp = message['timestamp'] as Timestamp?;
                          final dateLabel =
                              timestamp != null ? _getDateLabel(timestamp) : '';

                          // Show date separator if it's the first message or different date
                          final showDateSeparator =
                              index == _filteredMessages.length - 1 ||
                              (index < _filteredMessages.length - 1 &&
                                  _getDateLabel(
                                        _filteredMessages[index +
                                            1]['timestamp'],
                                      ) !=
                                      dateLabel);

                          if ((message['text']?.isEmpty ?? true) &&
                              (message['imageUrl']?.isEmpty ?? true) &&
                              (message['videoUrl']?.isEmpty ?? true) &&
                              (message['voiceUrl']?.isEmpty ?? true)) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              if (showDateSeparator)
                                GestureDetector(
                                  onTap: _showCalendarPicker,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      dateLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              MessageBubble(
                                message: message['text'] ?? '',
                                timestamp: message['timestamp'],
                                isMe: isMe,
                                senderName: message['senderName'] ?? 'User',
                                imageUrl: message['imageUrl'],
                                videoUrl: message['videoUrl'],
                                voiceUrl: message['voiceUrl'],
                                readCount:
                                    (message['readBy'] as List?)?.length ??
                                    1, // Add this line
                              ),
                            ],
                          );
                        },
                      ),
            ),
            if (_isRecording) _buildRecordingUI(),
            ChatInputField(
              controller: _messageController,
              onSend: _sendMessage,
              isSending: _isSending,
              onEmojiPressed: _toggleEmojiPicker,
              onMediaPressed: _pickMedia,
              isRecording: _isRecording,
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _messageController.text += emoji.emoji;
                  },
                  config: const Config(
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax: 32.0,
                      backgroundColor: Colors.white,
                    ),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: Colors.grey,
                      indicatorColor: Colors.blue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }
}
