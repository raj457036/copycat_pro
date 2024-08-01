import 'dart:async';

import 'package:copycat_pro/constants/number/values.dart';
import 'package:copycat_pro/widgets/drag_drop/drop_area.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

typedef ItemPriorityFilter = (DataFormat<Object>?, int)
    Function(List<DataFormat<Object>> itemFormats, {int prefScore});

typedef ItemPaster = Future<void> Function(
    Iterable<(DataReader, DataFormat<Object>)> readerSet);

class ClipDropRegion extends StatefulWidget {
  final Widget child;
  final ItemPriorityFilter itemPriorityFilter;
  final ItemPaster itemPaster;
  const ClipDropRegion({
    super.key,
    required this.child,
    required this.itemPriorityFilter,
    required this.itemPaster,
  });

  @override
  State<ClipDropRegion> createState() => _ClipDropRegionState();
}

class _ClipDropRegionState extends State<ClipDropRegion> {
  bool dropZoneActive = false;

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

  FutureOr<DropOperation> onDropOver(event) {
    if (event.session.allowedOperations.contains(DropOperation.copy)) {
      return DropOperation.copy;
    } else {
      return DropOperation.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: onDropOver,
      onDropEnter: onDropEnter,
      onDropLeave: onDropLeave,
      onDropEnded: onDropLeave,
      onPerformDrop: onPerformDrop,
      child: dropZoneActive ? const DropArea() : widget.child,
    );
  }

  Future<void> onPerformDrop(PerformDropEvent event) async {
    disableDropZone();
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
      final itemFormats = reader.getFormats(Formats.standardFormats);
      (selectedFormat, selectedPref) = widget.itemPriorityFilter(
        itemFormats,
        prefScore: selectedPref,
      );
      if (selectedFormat == null) continue;
      res.add((reader, selectedFormat));
      pastedCount++;
    }

    // if (items.length > kMaxDropItemCount) {
    //   showTextSnackbar(
    //     "Maximum $kMaxDropItemCount drop items are supported at once.",
    //   );
    // }

    await widget.itemPaster(res);
  }
}
