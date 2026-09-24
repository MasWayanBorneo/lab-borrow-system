import 'dart:io';
import '/app/models/item.dart';
import '/app/services/item_service.dart';
import 'controller.dart';

class AdminItemsController extends Controller {
  final ItemService itemService = ItemService();

  Future<List<Item>> load() => itemService.all();

  Future<void> create(Item item) => itemService.create(item);

  Future<void> update(Item item) => itemService.update(item);

  Future<void> delete(String id) => itemService.delete(id);

  Future<void> setReady(String id, bool isReady) =>
      itemService.setReady(id, isReady);

  Future<String> uploadImage(File file) => itemService.uploadImage(file);
}
