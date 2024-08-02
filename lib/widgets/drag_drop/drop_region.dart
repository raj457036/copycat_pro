import 'dart:async';

import 'package:copycat_base/bloc/offline_persistance_cubit/offline_persistance_cubit.dart';
import 'package:copycat_base/common/logging.dart';
import 'package:copycat_base/data/services/clipboard_service.dart';
import 'package:copycat_base/utils/snackbar.dart';
import 'package:copycat_pro/constants/number/values.dart';
import 'package:copycat_pro/widgets/drag_drop/drop_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ClipDropRegion extends StatefulWidget {
  final Widget child;

  const ClipDropRegion({
    super.key,
    required this.child,
  });

  @override
  State<ClipDropRegion> createState() => _ClipDropRegionState();
}

class _ClipDropRegionState extends State<ClipDropRegion> {
  bool dropZoneActive = false;
  bool processing = false;
  late final OfflinePersistanceCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<OfflinePersistanceCubit>();
  }

  bool dropAllowed(DropItem item) {
    if (item.localData is Map &&
        (item.localData as Map).containsKey("itemId")) {
      // This is a drag within the app and has custom local data set.
      return false;
    }
    return true;
  }

  void onDropEnter(DropEvent event) {
    final item = event.session.items.first;
    final isDropAllowed = dropAllowed(item);
    if (!isDropAllowed) return;
    enableDropZone();
  }

  void onDropLeave(DropEvent event) {
    disableDropZone();
  }

  void enableDropZone() =>
      !dropZoneActive ? setState(() => dropZoneActive = true) : null;

  void disableDropZone() =>
      dropZoneActive ? setState(() => dropZoneActive = false) : null;

  FutureOr<DropOperation> onDropOver(DropOverEvent event) {
    if (processing) return DropOperation.none;
    if (event.session.allowedOperations.contains(DropOperation.copy)) {
      final item = event.session.items.first;
      final isDropAllowed = dropAllowed(item);
      if (isDropAllowed) enableDropZone();
      return DropOperation.copy;
    } else {
      return DropOperation.none;
    }
  }

  Future<void> onPerformDrop(PerformDropEvent event) async {
    if (processing) return;
    setState(() => processing = true);
    try {
      final items = event.session.items;

      final isDropAllowed = dropAllowed(items.first);
      if (!isDropAllowed) return;

      final res = <(DataReader, DataFormat)>[];
      int selectedPref = -1;
      int pastedCount = 0;

      for (final item in items) {
        if (pastedCount >= kMaxDropItemCount) break;
        final reader = item.dataReader;
        if (reader == null) continue;
        DataFormat? selectedFormat;
        final itemFormats = reader.getFormats(allSupportedFormats);

        (selectedFormat, selectedPref) = cubit.clipboard.filterOutByPriority(
          itemFormats,
          prefScore: selectedPref,
        );
        if (selectedFormat == null) continue;
        res.add((reader, selectedFormat));
        pastedCount++;
      }

      if (items.length > kMaxDropItemCount) {
        showTextSnackbar(
          "Maximum $kMaxDropItemCount drop items are supported at once.",
        );
      }

      final clips = await cubit.clipboard.processMultipleReaderDataFormat(
        res,
        manual: true,
      );
      if (clips != null) {
        cubit.onClips(clips, manualPaste: true);
      }
    } catch (error) {
      logger.e(error);
    } finally {
      setState(() => processing = false);
      disableDropZone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: allSupportedFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: onDropOver,
      onDropEnter: onDropEnter,
      onDropLeave: onDropLeave,
      onDropEnded: onDropLeave,
      onPerformDrop: onPerformDrop,
      child: Stack(
        children: [
          widget.child,
          if (dropZoneActive)
            SizedBox.expand(
              child: DropArea(processing: processing),
            ),
        ],
      ),
    );
  }
}
