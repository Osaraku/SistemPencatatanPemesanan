import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/custom_navbar.dart';
import 'menu_page.dart';
import 'services/menu_service.dart';
import 'add_order_page.dart';
import 'income_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0 = Aktif, 1 = Selesai
  int _bottomNavIndex = 0;

  final MenuService _menuService = MenuService();
  List<Order> _allOrders = [];
  bool _isLoading = true;

  final List<Widget> _pages = [
    const SizedBox(),
    const IncomePage(),
    const MenuPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    List<Order> orders = await _menuService.getOrders();
    setState(() {
      _allOrders = orders;
      _isLoading = false;
    });
  }

  void _markAsDone(String orderId) async {
    await _menuService.completeOrder(orderId);
    _loadOrders();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan dipindahkan ke Selesai")),
    );
  }

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

          // --- TAB SWITCH DENGAN ANIMASI SLIDING ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double tabWidth = (constraints.maxWidth - 8) / 2;
                  return Stack(
                    children: [
                      // Latar Belakang Putih yang Sliding
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: _tabIndex == 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          width: tabWidth,
                          height: 42,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Label Tombol
                      Row(
                        children: [
                          _buildTabLabel("Aktif", 0),
                          _buildTabLabel("Selesai", 1),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

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
                      final order = filteredOrders[index];

                      // Slide delete hanya aktif untuk pesanan yang belum selesai (Tab Aktif)
                      if (_tabIndex == 0) {
                        return Dismissible(
                          key: Key(order.id),
                          direction:
                              DismissDirection.startToEnd, // Geser ke kanan
                          confirmDismiss: (direction) =>
                              _confirmDeleteOrder(order),
                          onDismissed: (direction) => _deleteOrder(order.id),
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          child: _buildOrderCard(order),
                        );
                      }
                      return _buildOrderCard(order);
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

      floatingActionButton: _bottomNavIndex == 0
          ? Container(
              margin: const EdgeInsets.only(bottom: 10, right: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A37C6), Color(0xFF6B5AE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A37C6).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddOrderPage(),
                      ),
                    );
                    if (result == true) {
                      _loadOrders();
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          "Tambah Pesanan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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

  // Widget Label Tab (Hanya Text)
  Widget _buildTabLabel(String title, int index) {
    bool isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          color: Colors.transparent, // Agar area klik luas
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isActive ? Colors.black : Colors.grey[600],
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  // WIDGET KARTU PESANAN
  Widget _buildOrderCard(Order order) {
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
          ...order.items.map((item) {
            final options = item['options'] as Map<String, dynamic>? ?? {};
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: _buildImage(item['imagePath']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
              if (_tabIndex == 0)
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

  Future<bool?> _confirmDeleteOrder(Order order) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Batalkan Pesanan"),
        content: Text(
          "Yakin ingin membatalkan pesanan #${order.id.substring(order.id.length - 4)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Kembali", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hapus Pesanan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(String orderId) async {
    await _menuService.deleteOrder(orderId);
    _loadOrders(); // Refresh list setelah hapus
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pesanan berhasil dibatalkan")),
      );
    }
  }
}
