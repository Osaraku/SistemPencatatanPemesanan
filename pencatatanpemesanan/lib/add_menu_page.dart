import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/menu_service.dart';

class AddMenuPage extends StatefulWidget {
  final MenuItem? menuToEdit; // BARU: Parameter opsional untuk data edit

  const AddMenuPage({super.key, this.menuToEdit});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory = "Nasi Goreng";
  File? _selectedImage;

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Panggil fungsi load kategori
    if (widget.menuToEdit != null) {
      _nameController.text = widget.menuToEdit!.name;
      _priceController.text = widget.menuToEdit!.price.toString();
    }
  }

  Future<void> _loadCategories() async {
    List<String> cats = await MenuService().getCategories();
    setState(() {
      _categories = cats;
      if (widget.menuToEdit != null) {
        _selectedCategory = widget.menuToEdit!.category;
      } else {
        _selectedCategory = cats.first;
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Helper untuk menampilkan gambar preview (Entah itu file baru atau asset lama)
  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      // Prioritas 1: Gambar baru yang dipilih user
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (widget.menuToEdit != null) {
      // Prioritas 2: Gambar lama dari menu yang sedang diedit
      String path = widget.menuToEdit!.imagePath;
      if (path.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(path, fit: BoxFit.cover, width: double.infinity),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.broken_image, color: Colors.grey),
                    Text(
                      "File Hilang",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    } else {
      // Prioritas 3: Tampilan placeholder kosong
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image, size: 40, color: Color(0xFF4A37C6)),
          SizedBox(height: 8),
          Text(
            "Ketuk untuk tambah gambar",
            style: TextStyle(color: Color(0xFF4A37C6)),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ubah judul berdasarkan mode (Tambah atau Edit)
    bool isEditing = widget.menuToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          isEditing ? "Edit Menu" : "Tambah Menu", // Judul Dinamis
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4A37C6).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: _buildImagePreview(), // Gunakan helper preview
                ),
              ),
              const SizedBox(height: 24),

              // ... (Kode input Nama, Tipe Menu, Harga TETAP SAMA seperti sebelumnya)
              const Text("Nama Menu", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Contoh: Nasi Goreng A",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              const Text("Tipe Menu", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              const Text("Harga", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Masukkan Harga",
                  suffixText: "Rupiah",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Harga tidak boleh kosong" : null,
              ),
              const SizedBox(height: 40),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A37C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveMenu,
                  child: Text(
                    isEditing
                        ? "Simpan Perubahan"
                        : "Tambah Menu", // Teks Dinamis
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMenu() async {
    // Validasi gambar: Harus ada gambar baru ATAU sedang edit (gambar lama ada)
    if (_selectedImage == null && widget.menuToEdit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon pilih gambar menu terlebih dahulu"),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Tentukan path gambar: Pakai gambar baru jika ada, kalau tidak pakai gambar lama
      String finalImagePath;
      if (_selectedImage != null) {
        finalImagePath = _selectedImage!.path;
      } else {
        finalImagePath = widget.menuToEdit!.imagePath;
      }

      final newMenuData = MenuItem(
        name: _nameController.text,
        category: _selectedCategory,
        price: int.parse(_priceController.text),
        imagePath: finalImagePath,
      );

      // LOGIKA SIMPAN: Tambah atau Update
      if (widget.menuToEdit != null) {
        // Mode Edit
        await MenuService().updateMenu(widget.menuToEdit!, newMenuData);
      } else {
        // Mode Tambah
        await MenuService().addMenu(newMenuData);
      }

      if (mounted) {
        Navigator.pop(context, true); // Kembali dengan sinyal refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.menuToEdit != null
                  ? "Menu diperbarui!"
                  : "Menu ditambahkan!",
            ),
          ),
        );
      }
    }
  }
}
