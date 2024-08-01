import 'package:copycat_base/constants/widget_styles.dart';
import 'package:copycat_base/utils/common_extension.dart';
import 'package:flutter/material.dart';

class DropArea extends StatelessWidget {
  const DropArea({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    return SizedBox.expand(
      child: ColoredBox(
        color: colors.secondaryContainer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.downloading_outlined,
              size: 95,
            ),
            height16,
            Text(
              "Drop your files, images or text here",
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
