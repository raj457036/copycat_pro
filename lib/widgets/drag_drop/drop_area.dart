import 'package:copycat_base/constants/widget_styles.dart';
import 'package:copycat_base/l10n/l10n.dart';
import 'package:copycat_base/utils/common_extension.dart';
import 'package:flutter/material.dart';

class DropArea extends StatelessWidget {
  final bool processing;
  const DropArea({
    super.key,
    this.processing = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colors;
    return ColoredBox(
      color: colors.secondaryContainer.withOpacity(0.85),
      child: processing
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(padding12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.blur_on_rounded,
                    size: 95,
                    color: colors.onSecondaryContainer,
                  ),
                  height16,
                  Text(
                    context.locale.dropHere,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
