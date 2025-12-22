import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/menu_service.dart';
import 'menu_detail_page.dart'; // Import halaman detail baru

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final MenuService _menuService = MenuService();
  List<MenuItem> _allMenus = [];
  bool _isLoading = true;

  // KERANJANG BELANJA BARU: List of Map (Karena item yang sama bisa punya opsi beda)
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    List<MenuItem> menus = await _menuService.getMenus();
    setState(() {
      _allMenus = menus;
      _isLoading = false;
    });
  }

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.fastfood, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  // Menghitung Total Harga
  int _calculateTotal() {
    int total = 0;
    for (var item in _cartItems) {
      MenuItem menu = item['menu'];
      int qty = item['qty'];
      total += (menu.price * qty);
    }
    return total;
  }

  // Navigasi ke Halaman Detail
  void _openDetail(MenuItem menu) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MenuDetailPage(menu: menu)),
    );

    // Jika user menekan tombol "Tambah" di detail page
    if (result != null) {
      setState(() {
        _cartItems.add(result);
      });
    }
  }

  void _submitOrder() async {
    if (_cartItems.isEmpty) return;

    // Konversi struktur data untuk disimpan ke SharedPrefs
    // (Kita flat-kan structure-nya agar sesuai dengan model Order yang ada)
    List<Map<String, dynamic>> finalOrderItems = _cartItems.map((item) {
      MenuItem menu = item['menu'];
      return {
        'name': menu.name,
        'price': menu.price,
        'qty': item['qty'],
        'imagePath': menu.imagePath,
        'options': item['options'], // Simpan Opsi di sini
      };
    }).toList();

    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: finalOrderItems,
      totalPrice: _calculateTotal(),
      date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      isCompleted: false,
    );

    await _menuService.addOrder(newOrder);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pesanan berhasil dibuat!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan menu untuk tampilan
    Map<String, List<MenuItem>> groupedMenus = {};
    for (var menu in _allMenus) {
      if (!groupedMenus.containsKey(menu.category)) {
        groupedMenus[menu.category] = [];
      }
      groupedMenus[menu.category]!.add(menu);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Pesanan Baru",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: groupedMenus.entries.map((entry) {
                      return _buildCategorySection(entry.key, entry.value);
                    }).toList(),
                  ),
                ),

                // Bottom Bar Checkout
                if (_cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${_cartItems.length} Item di Keranjang",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "Total: Rp ${_calculateTotal()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF4A37C6),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A37C6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submitOrder,
                            child: const Text(
                              "Proses Pesanan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
          height: 250,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (c, i) => const SizedBox(width: 15),
            itemBuilder: (context, index) => _buildMenuCard(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(MenuItem menu) {
    return Container(
      width: 160,
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
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Rp ${menu.price}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4A37C6),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFF4A37C6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      // TOMBOL TAMBAH SEKARANG MEMBUKA HALAMAN DETAIL
                      onPressed: () => _openDetail(menu),
                      child: const Text(
                        "Tambah",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
