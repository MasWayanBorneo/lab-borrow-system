import 'dart:io';
import '/app/models/item.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ItemService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Item>> all({String? category, String? search}) async {
    var query = _client.from('items').select();

    if (category != null && category.isNotEmpty && category != 'Semua') {
      query = query.eq('category', category);
    }
    if (search != null && search.isNotEmpty) {
      query = query.ilike('name', '%$search%');
    }

    final data = await query.order('name');
    return List.from(data).map((json) => Item.fromJson(json)).toList();
  }

  Future<Item> find(String id) async {
    final data = await _client.from('items').select().eq('id', id).single();
    return Item.fromJson(data);
  }

  Future<void> create(Item item) async {
    await _client.from('items').insert({
      "name": item.name,
      "code": item.code,
      "category": item.category,
      "total_qty": item.totalQty,
      "available_qty": item.totalQty,
      "image_url": item.imageUrl,
      "is_ready": item.isReady,
    });
  }

  Future<void> update(Item item) async {
    await _client.from('items').update({
      "name": item.name,
      "code": item.code,
      "category": item.category,
      "total_qty": item.totalQty,
      "image_url": item.imageUrl,
      "is_ready": item.isReady,
    }).eq('id', item.id as Object);
  }

  Future<void> setReady(String id, bool isReady) async {
    await _client.from('items').update({
      "is_ready": isReady,
    }).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('items').delete().eq('id', id);
  }

  Future<String> uploadImage(File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

    await _client.storage.from('item-images').upload(fileName, file);

    return _client.storage.from('item-images').getPublicUrl(fileName);
  }
}
