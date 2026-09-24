import 'dart:io';
import '/app/models/item.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const List<String> kItemCategories = ["Jaringan", "Multimedia", "Elektronika"];

class ItemFormSheet extends StatefulWidget {
  const ItemFormSheet({
    super.key,
    this.existing,
    required this.uploadImage,
    required this.onSave,
  });

  final Item? existing;
  final Future<String> Function(File file) uploadImage;
  final Future<void> Function(Item item) onSave;

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _qtyController;
  late String _category;
  late bool _isReady;
  File? _pickedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Item? existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? "");
    _codeController = TextEditingController(text: existing?.code ?? "");
    _qtyController =
        TextEditingController(text: existing?.totalQty?.toString() ?? "");
    _category = existing?.category ?? kItemCategories.first;
    _isReady = existing?.isReady ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (file == null) return;
    setState(() => _pickedImage = File(file.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      String? imageUrl = widget.existing?.imageUrl;
      if (_pickedImage != null) {
        imageUrl = await widget.uploadImage(_pickedImage!);
      }

      Item item = Item()
        ..id = widget.existing?.id
        ..name = _nameController.text.trim()
        ..code = _codeController.text.trim()
        ..category = _category
        ..totalQty = int.parse(_qtyController.text.trim())
        ..imageUrl = imageUrl
        ..isReady = _isReady;

      await widget.onSave(item);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? "Edit Alat" : "Tambah Alat",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, height: 140, fit: BoxFit.cover)
                      : (widget.existing?.imageUrl != null
                          ? Image.network(widget.existing!.imageUrl!,
                              height: 140, fit: BoxFit.cover)
                          : Container(
                              height: 140,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.add_photo_alternate_outlined,
                                  size: 40),
                            )),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Alat"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "Kode Inventaris"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: kItemCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: "Jumlah Total"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Wajib diisi";
                  if (int.tryParse(v.trim()) == null) return "Harus angka";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isReady,
                title: const Text("Siap Dipinjam"),
                subtitle: Text(
                  _isReady
                      ? "Alat dalam kondisi baik"
                      : "Alat rusak / sedang diperbaiki",
                ),
                onChanged: (value) => setState(() => _isReady = value),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
