import 'package:copycat_base/common/paginated_results.dart';
import 'package:copycat_base/db/clip_collection/clipcollection.dart';
import 'package:copycat_base/db/clipboard_item/clipboard_item.dart';
import 'package:copycat_base/domain/sources/sync_clipboard.dart';
import 'package:copycat_base/utils/utility.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Named("remote")
@LazySingleton(as: SyncClipboardSource)
class SyncClipboardSourceImpl implements SyncClipboardSource {
  final SupabaseClient client;
  final String clipboardItemsTable = "clipboard_items";
  final String clipCollectionsTable = "clip_collections";

  SyncClipboardSourceImpl(this.client);

  PostgrestClient get db => client.rest;

  @override
  Future<PaginatedResult<ClipboardItem>> getLatestClipboardItems({
    required String userId,
    int limit = 100,
    int offset = 0,
    String? excludeDeviceId,
    DateTime? lastSynced,
  }) async {
    var query = db
        .from(clipboardItemsTable)
        .select()
        .eq("userId", userId)
        .isFilter("deletedAt", null);

    if (lastSynced != null) {
      final isoDate = lastSynced
          .subtract(const Duration(seconds: 5))
          .toUtc()
          .toIso8601String();
      query = query.gt("modified", isoDate);
    }

    if (excludeDeviceId != null && excludeDeviceId != "") {
      query = query.neq("deviceId", excludeDeviceId);
    }

    final docs = await query.order("modified").range(offset, offset + limit);
    final clips = (await Future.wait(docs
            .map((e) => ClipboardItem.fromJson(e))
            .map((e) => e.copyWith(lastSynced: now()))
            .map((e) => e.decrypt())))
        .toList();
    return PaginatedResult(
      results: clips,
      hasMore: clips.length > limit,
    );
  }

  @override
  Future<PaginatedResult<ClipCollection>> getLatestClipCollections({
    required String userId,
    int limit = 100,
    int offset = 0,
    String? excludeDeviceId,
    DateTime? lastSynced,
  }) async {
    var query = db
        .from(clipCollectionsTable)
        .select()
        .eq("userId", userId)
        .isFilter("deletedAt", null);

    if (lastSynced != null) {
      final isoDate = lastSynced
          .subtract(const Duration(seconds: 5))
          .toUtc()
          .toIso8601String();
      query = query.gt(
        "modified",
        isoDate,
      );
    }
    if (excludeDeviceId != null && excludeDeviceId != "") {
      query = query.neq("deviceId", excludeDeviceId);
    }
    final docs = await query.order("modified").range(offset, offset + limit);
    final items = docs
        .map((e) => ClipCollection.fromJson(e))
        .map((e) => e.copyWith(lastSynced: now()))
        .toList();
    return PaginatedResult(
      results: items,
      hasMore: items.length > limit,
    );
  }

  @override
  Future<PaginatedResult<ClipboardItem>> getDeletedClipboardItems({
    required String userId,
    int limit = 100,
    int offset = 0,
    String? excludeDeviceId,
    DateTime? lastSynced,
  }) async {
    if (lastSynced == null) return PaginatedResult.empty();
    final isoDate = lastSynced
        .subtract(const Duration(seconds: 5))
        .toUtc()
        .toIso8601String();
    var query = db
        .from(clipboardItemsTable)
        .select()
        .eq("userId", userId)
        .gte("deletedAt", isoDate);

    if (excludeDeviceId != null && excludeDeviceId != "") {
      query = query.neq("deviceId", excludeDeviceId);
    }
    final docs = await query.order("modified").range(offset, offset + limit);
    final items = docs.map((e) => ClipboardItem.fromJson(e)).toList();
    return PaginatedResult(
      results: items,
      hasMore: items.length > limit,
    );
  }

  @override
  Future<PaginatedResult<ClipCollection>> getDeletedClipCollections({
    required String userId,
    int limit = 100,
    int offset = 0,
    String? excludeDeviceId,
    DateTime? lastSynced,
  }) async {
    if (lastSynced == null) return PaginatedResult.empty();

    final isoDate = lastSynced
        .subtract(const Duration(seconds: 5))
        .toUtc()
        .toIso8601String();
    var query = db
        .from(clipCollectionsTable)
        .select()
        .eq("userId", userId)
        .gte("deletedAt", isoDate);

    if (excludeDeviceId != null && excludeDeviceId != "") {
      query = query.neq("deviceId", excludeDeviceId);
    }
    final docs = await query.order("modified").range(offset, offset + limit);
    final items = docs.map((e) => ClipCollection.fromJson(e)).toList();
    return PaginatedResult(
      results: items,
      hasMore: items.length > limit,
    );
  }
}
