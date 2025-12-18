import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/custom_navbar.dart';
import 'menu_page.dart';
import 'services/menu_service.dart';
import 'add_order_page.dart'; // Import halaman tambah pesanan
import 'income_page.dart'; // Import halaman pendapatan

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0 = Aktif, 1 = Selesai
  int _bottomNavIndex = 0;

  // Service
  final MenuService _menuService = MenuService();
  List<Order> _allOrders = [];
  bool _isLoading = true;

  final List<Widget> _pages = [
    const SizedBox(), // Placeholder untuk index 0
    const IncomePage(),
    const MenuPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Load Data Order
  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    List<Order> orders = await _menuService.getOrders();
    setState(() {
      _allOrders = orders;
      _isLoading = false;
    });
  }

  // Mark Order as Complete
  void _markAsDone(String orderId) async {
    await _menuService.completeOrder(orderId);
    _loadOrders(); // Refresh list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan dipindahkan ke Selesai")),
    );
  }

  // Helper menampilkan gambar
  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_bottomNavIndex == 0) {
      // --- LOGIC HALAMAN UTAMA (LIST PESANAN) ---

      // Filter list berdasarkan tab (Aktif / Selesai)
      // Tab 0 (Aktif) = cari yang isCompleted == false
      // Tab 1 (Selesai) = cari yang isCompleted == true
      List<Order> filteredOrders = _allOrders.where((order) {
        return _tabIndex == 0 ? !order.isCompleted : order.isCompleted;
      }).toList();

      if (_tabIndex == 1) {
        filteredOrders = filteredOrders.reversed.toList();
      }

      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'List Pesanan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Tab Switch (Aktif / Selesai)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabItem("Aktif", 0),
                  _buildTabItem("Selesai", 1),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // LIST DATA ORDER
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                ? Center(
                    child: Text(
                      _tabIndex == 0
                          ? "Belum ada pesanan aktif"
                          : "Belum ada pesanan selesai",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      );
    } else {
      bodyContent = _pages[_bottomNavIndex];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: bodyContent),

      // FAB HANYA MUNCUL DI TAB "PESANAN" (INDEX 0)
      floatingActionButton: _bottomNavIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 10),
              child: SizedBox(
                height: 50,
                width: 170,
                child: FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF4A37C6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: () async {
                    // Buka halaman Tambah Pesanan
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddOrderPage(),
                      ),
                    );
                    // Jika sukses submit, refresh list
                    if (result == true) {
                      _loadOrders();
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Tambah\nPesanan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          : null,

      bottomNavigationBar: CustomNavbar(
        selectedIndex: _bottomNavIndex,
        onItemSelected: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }

  // WIDGET KARTU PESANAN
  Widget _buildOrderCard(Order order) {
    // Karena satu "Order" sekarang bisa berisi banyak item yang berbeda-beda opsinya,
    // Kita akan menampilkan list itemnya di dalam kartu tersebut.

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Order (ID & Tanggal)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${order.id.substring(order.id.length - 4)}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                order.date,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(),

          // LOOPING SEMUA ITEM DI DALAM ORDER INI
          ...order.items.map((item) {
            // Ambil opsi (gunakan map kosong jika null agar aman)
            final options = item['options'] as Map<String, dynamic>? ?? {};

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Kecil
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: _buildImage(item['imagePath']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Detail Item & Opsi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Menu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF4A37C6),
                                ),
                              ),
                            ),
                            // Tipe Makan (Makan di tempat/Bungkus) tampil di pojok kanan
                            if (options['type'] != null)
                              Text(
                                options['type'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // OPSI-OPSI DETAIL
                        if (options.isNotEmpty) ...[
                          Text(
                            "Kepedasan: ${options['level'] ?? '-'}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Telur: ${options['egg'] ?? '-'}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Pembayaran: ${options['payment'] ?? '-'}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                        const SizedBox(height: 4),
                        // Qty & Harga
                        Text(
                          "${item['qty']}x  @ Rp ${item['price']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const Divider(),

          // Footer Total Harga & Tombol Selesai
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: Rp ${order.totalPrice}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              if (_tabIndex == 0) // Tombol Selesai hanya jika di tab Aktif
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A37C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: () => _markAsDone(order.id),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              else
                const Text(
                  "Selesai",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Tab Switch (Aktif/Selesai) - Tetap sama
  Widget _buildTabItem(String title, int index) {
    bool isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
