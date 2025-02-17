import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class IconAndTextWidget extends StatefulWidget {
  final IconData? iconData;
  final String? text;
  final double? fontSize;
  final double? iconSize;
  final Function()? onTap;
  final bool isExpandable;
  final Widget? expandedContent;

  const IconAndTextWidget({
    super.key,
    required this.iconData,
    required this.iconSize,
    required this.text,
    required this.fontSize,
    this.onTap,
    this.isExpandable = false,
    this.expandedContent,
  });

  @override
  _IconAndTextWidgetState createState() => _IconAndTextWidgetState();
}

class _IconAndTextWidgetState extends State<IconAndTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconRotation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      if (_isExpanded) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.isExpandable ? _toggleExpand : widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.iconData,
                      color: kPrimaryColor1,
                      size: widget.iconSize,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.text!,
                      style: TextStyle(
                        color: kFontColor,
                        fontSize: widget.fontSize,
                      ),
                    ),
                  ],
                ),
                if (widget.isExpandable)
                  RotationTransition(
                    turns: _iconRotation,
                    child: const Icon(
                      Icons.expand_more,
                      color: kPrimaryColor1,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.isExpandable &&
            _isExpanded &&
            widget.expandedContent != null)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 10),
            child: widget.expandedContent,
          ),
      ],
    );
  }
}
