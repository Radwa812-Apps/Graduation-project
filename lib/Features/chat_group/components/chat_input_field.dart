/*import 'package:flutter/material.dart';

import '../../../core/constants.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.attach_file, color: Colors.black54),
                  const SizedBox(width: 8),
                  const Icon(Icons.camera_alt_outlined, color: Colors.black54),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend, 
            child: const CircleAvatar(
              radius: 21,
              backgroundColor: kPrimaryColor1,
              child: Icon(
                Icons.send_outlined,
                color: background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
/*import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isTyping;
  final VoidCallback onEmojiPressed;
  final VoidCallback onMediaPressed;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.onSend,
    this.isTyping = false,
    required this.onEmojiPressed,
    required this.onMediaPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, 
                        color: Colors.black54),
                    onPressed: onEmojiPressed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, 
                        color: Colors.black54),
                    onPressed: onMediaPressed,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, 
                        color: Colors.black54),
                    onPressed: () {
                      // Handle camera
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isTyping ? onSend : null,
            child: CircleAvatar(
              radius: 21,
              backgroundColor: isTyping ? kPrimaryColor1 : Colors.grey,
              child: Icon(
                Icons.send_outlined,
                color: background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onEmojiPressed;
  final VoidCallback onMediaPressed;
  final bool isSending;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onEmojiPressed,
    required this.onMediaPressed,
    this.isSending = false,
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() => _showSendButton = widget.controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, 
                        color: Colors.black54),
                    onPressed: widget.onEmojiPressed,
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, 
                        color: Colors.black54),
                    onPressed: widget.onMediaPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, 
                        color: Colors.black54),
                    onPressed: () {
                      // Optional: Add camera functionality here
                      widget.onMediaPressed();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showSendButton && !widget.isSending ? widget.onSend : null,
            child: CircleAvatar(
              radius: 21,
              backgroundColor: _showSendButton 
                  ? kPrimaryColor1 
                  : Colors.grey[400],
              child: widget.isSending
                  ? const CircularProgressIndicator(
                      color: background,
                      strokeWidth: 2,
                    )
                  : const Icon(
                      Icons.send_outlined,
                      color: background,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Added for Firebase Storage
import '../../../core/constants.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onEmojiPressed;
  final VoidCallback onMediaPressed;
  final bool isSending;
  final Function(String) onVoiceMessageRecorded;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onEmojiPressed,
    required this.onMediaPressed,
    required this.onVoiceMessageRecorded,
    this.isSending = false,
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _showSendButton = false;
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _recordedFilePath;
  bool _isCancelled = false;
  double _dragDistance = 0.0;
  int _recordingDuration = 0; // Duration in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      print('Recorder opened successfully');
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission not granted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please grant microphone permission to record voice messages')),
          );
        }
      }
    } catch (e) {
      print('Error initializing recorder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize recorder: $e')),
        );
      }
    }
  }

  void _handleTextChange() {
    setState(() => _showSendButton = widget.controller.text.isNotEmpty);
  }

  void _startTimer() {
    _recordingDuration = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _recordingDuration = 0;
    });
  }

  Future<void> _startRecording() async {
    if (_recorder == null || _isRecording) return;

    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Microphone permission is required to record')),
          );
        }
        return;
      }

      setState(() {
        _isRecording = true;
        _isCancelled = false;
        _dragDistance = 0.0;
      });

      final tempDir = await getTemporaryDirectory();
      _recordedFilePath = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: _recordedFilePath, codec: Codec.aacADTS);
      print('Recording started at: $_recordedFilePath');

      _startTimer(); // Start the timer
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
      setState(() {
        _isRecording = false;
      });
      _stopTimer();
      await _initRecorder(); // Try to reinitialize if it failed
    }
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    if (_recorder == null || !_isRecording) return;

    try {
      await _recorder!.stopRecorder();
      print('Recording stopped: $_recordedFilePath');

      if (cancel && _recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
        print('Recording cancelled and file deleted');
      } else if (_recordedFilePath != null && !cancel) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          widget.onVoiceMessageRecorded(_recordedFilePath!); // Send only if file exists
          _recordedFilePath = null; // Reset after sending
        } else {
          print('Error: Recorded file does not exist at $_recordedFilePath');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Recorded file not found. Please try again.')),
            );
          }
        }
      }

      setState(() {
        _isRecording = false;
        _isCancelled = false;
        _dragDistance = 0.0;
      });
      _stopTimer();
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
      setState(() {
        _isRecording = false;
        _isCancelled = false;
        _dragDistance = 0.0;
      });
      _stopTimer();
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined, color: Colors.black54),
                        onPressed: widget.onEmojiPressed,
                      ),
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          decoration: const InputDecoration(
                            hintText: "Message",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Colors.black54),
                        onPressed: widget.onMediaPressed,
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined, color: Colors.black54),
                        onPressed: () {
                          widget.onMediaPressed();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showSendButton && !widget.isSending ? widget.onSend : null,
                onLongPressStart: (_) {
                  if (!_showSendButton) _startRecording();
                },
                onLongPressMoveUpdate: (details) {
                  if (!_showSendButton && _isRecording) {
                    setState(() {
                      _dragDistance = -details.offsetFromOrigin.dx; // Negative for left drag
                      if (_dragDistance > 100) {
                        _isCancelled = true;
                      } else {
                        _isCancelled = false;
                      }
                    });
                  }
                },
                onLongPressEnd: (_) {
                  if (!_showSendButton && _isRecording) {
                    _stopRecording(cancel: _isCancelled);
                  }
                },
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: _showSendButton
                      ? kPrimaryColor1
                      : (_isRecording ? Colors.red : Colors.grey[400]),
                  child: widget.isSending
                      ? const CircularProgressIndicator(
                          color: background,
                          strokeWidth: 2,
                        )
                      : Icon(
                          _showSendButton
                              ? Icons.send_outlined
                              : (_isRecording ? Icons.stop : Icons.mic),
                          color: background,
                        ),
                ),
              ),
            ],
          ),
          // Visual feedback while recording
          if (_isRecording)
            Positioned(
              left: 20,
              child: Row(
                children: [
                  Text(
                    _formatDuration(_recordingDuration),
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.mic,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  if (_dragDistance > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Slide to cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  if (_isCancelled)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _recorder?.closeRecorder();
    _recorder = null;
    _stopTimer();
    super.dispose();
  }
}