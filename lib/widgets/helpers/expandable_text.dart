import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';

class ExpandableTextRow extends StatefulWidget {
  final String ex;

  const ExpandableTextRow({super.key, required this.ex});

  @override
  State<ExpandableTextRow> createState() => ExpandableTextRowState();
}

class ExpandableTextRowState extends State<ExpandableTextRow> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              widget.ex,
              maxLines: isExpanded ? null : 2,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold
            ),
          ),
        ],
      ),
    );
  }
}