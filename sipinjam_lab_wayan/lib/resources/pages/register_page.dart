import 'dart:io';
import '/app/controllers/register_controller.dart';
import '/app/forms/register_form.dart';
import '/resources/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegisterPage extends NyStatefulWidget<RegisterController> {
  static RouteView path = ("/register", (_) => RegisterPage());

  RegisterPage({super.key}) : super(child: () => _RegisterPageState());
}

class _RegisterPageState extends NyPage<RegisterPage> {
  File? _ktmFile;

  @override
  get init => () {};

  @override
  LoadingStyle get loadingStyle => LoadingStyle.none();

  Future<void> _pickKtm() async {
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (file == null) return;
    setState(() => _ktmFile = File(file.path));
  }

  Future<void> _onSubmit(dynamic data) async {
    if (_ktmFile == null) {
      showToastDanger(description: "Unggah foto KTM/KTP terlebih dahulu");
      return;
    }

    try {
      await widget.controller.register(
        name: data["name"],
        nim: data["nim"],
        email: data["email"],
        password: data["password"],
        ktmFile: _ktmFile,
      );

      showToastSuccess(description: "Akun berhasil dibuat, silakan masuk");
      pop();
    } catch (e) {
      showToastDanger(description: "Gagal mendaftar ");
    }
  }

  Widget _ktmPicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickKtm,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _ktmFile != null
            ? Image.file(_ktmFile!, height: 140, fit: BoxFit.cover, width: double.infinity)
            : Container(
                height: 140,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.badge_outlined, size: 32),
                    SizedBox(height: 8),
                    Text("Unggah Foto KTM/KTP"),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ktmPicker(context),
              const SizedBox(height: 16),
              RegisterForm(
                onSubmit: _onSubmit,
                submitButton: Button.primary(text: "Daftar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
