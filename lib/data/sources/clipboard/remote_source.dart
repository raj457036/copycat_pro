import 'package:copycat_base/common/paginated_results.dart';
import 'package:copycat_base/db/clipboard_item/clipboard_item.dart';
import 'package:copycat_base/domain/sources/clipboard.dart';
import 'package:copycat_base/enums/clip_type.dart';
import 'package:copycat_base/enums/sort.dart';
import 'package:copycat_base/utils/utility.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Named("remote")
@LazySingleton(as: ClipboardSource)
class RemoteClipboardSource implements ClipboardSource {
  final SupabaseClient client;
  final String table = "clipboard_items";

  RemoteClipboardSource(this.client);

  PostgrestClient get db => client.rest;

  @override
  Future<ClipboardItem> create(ClipboardItem item) async {
    final docs = await db.from(table).insert(item.toJson()).select();
    final createdItem = item.copyWith(
      serverId: docs.first["id"],
      lastSynced: now(),
    )..applyId(item);

    return createdItem;
  }

  /// sortBy is no-op
  @override
  Future<PaginatedResult<ClipboardItem>> getList({
    int limit = 50,
    int offset = 0,
    DateTime? afterDate,
    String? search,
    List<String>? category, // no-op
    List<ClipItemType>? types, // no-op
    int? collectionId,
    ClipboardSortKey? sortBy,
    SortOrder order = SortOrder.desc,
  }) async {
    final items = await db
        .from(table)
        .select()
        .order("modified")
        .range(offset, limit + offset);

    final clips = (items.map((e) => ClipboardItem.fromJson(e))).toList();

    return PaginatedResult(results: clips, hasMore: clips.length == limit);
  }

  @override
  Future<ClipboardItem> update(ClipboardItem item) async {
    if (item.serverId == null) {
      return await create(item);
    }

    await db.from(table).update(item.toJson()).eq("id", item.serverId!);
    return item;
  }

  @override
  Future<bool> delete(ClipboardItem item) async {
    if (item.serverId == null) {
      return true;
    }

    item = item.copyWith(deletedAt: now(), modified: now());
    await db.from(table).update(item.toJson()).eq("id", item.serverId!);
    return true;
  }

  @override
  Future<bool> deleteAll() {
    throw UnimplementedError();
  }

  @override
  Future<ClipboardItem?> get({int? id, String? serverId}) async {
    if (serverId == null) return null;
    final item = await db.from(table).select().eq("id", serverId);
    if (item.isEmpty) return null;
    final clipItem = ClipboardItem.fromJson(item.first);
    return clipItem;
  }

  @override
  Future<ClipboardItem?> getLatest() {
    throw UnimplementedError();
  }

  @override
  Future<void> decryptPending() {
    throw UnimplementedError();
  }
}
