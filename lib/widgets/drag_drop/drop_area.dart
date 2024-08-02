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
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.black87,
        child: processing
            ? const CircularProgressIndicator.adaptive()
            : Column(
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
                    context.locale.dropHere,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
