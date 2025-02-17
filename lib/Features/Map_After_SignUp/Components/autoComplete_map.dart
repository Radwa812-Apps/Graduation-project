import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/map.dart';

class AutoCompleteSearch extends StatefulWidget {
  const AutoCompleteSearch(
      {super.key,
      required this.service,
      required this.controller,
      required this.GetSearchedPlace});
  final MapServices service;
  final TextEditingController controller;
  final Function(String) GetSearchedPlace;
  @override
  State<AutoCompleteSearch> createState() => _AutoCompleteSearchState();
}

class _AutoCompleteSearchState extends State<AutoCompleteSearch> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final suggestions = await widget.service
            .handleAutoCompleteSearch(textEditingValue.text);
        return suggestions ?? <String>[];
      },
      onSelected: (String selection) async {
        widget.controller.text = selection;
        log(widget.controller.text);
        setState(() {});
        await widget.GetSearchedPlace(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(60),
              borderSide: BorderSide.none,
            ),
            // suffixIcon: const Icon(Icons.search, color: kPrimaryColor1),

            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: kPrimaryColor1),
              onPressed: () async {
                await widget.GetSearchedPlace(
                    ''); // استدعاء الدالة بقيمة فارغةw
                widget.controller.clear(); // مسح النص في TextField
              },
            ),
          ),
          onSubmitted: (value) async {
            await widget.GetSearchedPlace(value);
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    onSelected(option);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
