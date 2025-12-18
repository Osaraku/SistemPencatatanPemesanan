import 'dart:io';

import 'package:flutter/material.dart';
import 'services/menu_service.dart';
import 'add_menu_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final MenuService _menuService = MenuService();
  List<MenuItem> _allMenus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    List<MenuItem> menus = await _menuService.getMenus();
    setState(() {
      _allMenus = menus;
      _isLoading = false;
    });
  }

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      // Jika path dimulai dengan 'assets/', gunakan Image.asset
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Placeholder jika asset tidak ditemukan
          return const Icon(Icons.fastfood, size: 50, color: Colors.grey);
        },
      );
    } else {
      // Jika tidak, asumsikan itu adalah path file lokal dari upload user
      return Image.file(
        File(path), // Membutuhkan import 'dart:io';
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Placeholder jika file lokal terhapus/rusak
          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    }
  }

  // Format Rupiah
  String formatRupiah(int price) {
    // Kalau belum pakai package intl, manual saja:
    return "Rp ${price.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan menu berdasarkan kategori
    Map<String, List<MenuItem>> groupedMenus = {};
    for (var menu in _allMenus) {
      if (!groupedMenus.containsKey(menu.category)) {
        groupedMenus[menu.category] = [];
      }
      groupedMenus[menu.category]!.add(menu);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'List Menu',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(
                            bottom: 80,
                          ), // Space for FAB
                          children: groupedMenus.entries.map((entry) {
                            return _buildCategorySection(
                              entry.key,
                              entry.value,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  // FAB Floating (Tombol Tambah Menu) seperti desain
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: SizedBox(
                      height: 50,
                      child: FloatingActionButton.extended(
                        backgroundColor: const Color(0xFF4A37C6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onPressed: () async {
                          // Navigasi ke Halaman Tambah Menu
                          bool? isAdded = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddMenuPage(),
                            ),
                          );
                          // Jika kembali membawa data 'true', refresh list
                          if (isAdded == true) {
                            _loadData();
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Tambah\nMenu",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategorySection(String category, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Menu $category",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220, // Tinggi area scroll horizontal
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (c, i) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final menu = items[index];
              return _buildMenuCard(menu);
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMenuCard(MenuItem menu) {
    return GestureDetector(
      // Gunakan GestureDetector untuk mendeteksi tap
      onTap: () {
        _showActionDialog(menu); // Tampilkan dialog saat diklik
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Gambar Menu (Tetap sama)
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Container(
                  color: Colors.grey[100],
                  width: double.infinity,
                  child: _buildImage(menu.imagePath),
                ),
              ),
            ),
            // Info Menu (Tetap sama)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      menu.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(menu.price),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(MenuItem menu) {
    showModalBottomSheet(
      context: context, // Ini adalah context Halaman (Aman)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Menu'),
                onTap: () async {
                  // 1. Tutup dialog menggunakan context milik sheet
                  Navigator.pop(sheetContext);

                  // 2. Buka halaman Edit menggunakan context Halaman (yang paling atas)
                  // JANGAN pakai sheetContext disini karena sudah di-pop (mati)
                  bool? isUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMenuPage(menuToEdit: menu),
                    ),
                  );

                  if (isUpdated == true) {
                    _loadData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Menu'),
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                  ); // Gunakan sheetContext juga disini
                  _confirmDelete(menu);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(MenuItem menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Menu"),
        content: Text("Apakah Anda yakin ingin menghapus '${menu.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await _menuService.deleteMenu(menu); // Hapus data
              _loadData(); // Refresh tampilan
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Menu berhasil dihapus")),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
