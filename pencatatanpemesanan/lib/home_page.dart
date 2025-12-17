import 'package:flutter/material.dart';
import 'widgets/custom_navbar.dart';
import 'menu_page.dart'; // 1. Pastikan meng-import file menu_page.dart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // Untuk Tab Aktif/Selesai
  int _bottomNavIndex = 0; // Untuk Navbar Bawah

  // 2. Daftar halaman diperbarui: Index 2 sekarang memanggil MenuPage()
  final List<Widget> _pages = [
    const Center(child: Text("Halaman List Pesanan")), // Placeholder index 0
    const Center(child: Text("Halaman Pendapatan")), // Placeholder index 1
    const MenuPage(), // <--- Halaman List Menu yang asli
  ];

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_bottomNavIndex == 0) {
      // TAMPILAN KHUSUS TAB "PESANAN" (Index 0)
      // Kita pertahankan layout custom untuk halaman utama/pesanan ini
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
          // Tab Switch (Aktif/Selesai)
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
          const Expanded(child: Center(child: Text("Belum ada pesanan aktif"))),
        ],
      );
    } else {
      // UNTUK TAB LAIN (Pendapatan & List Menu)
      // Menggunakan halaman dari daftar _pages
      bodyContent = _pages[_bottomNavIndex];
    }

    return Scaffold(
      backgroundColor: Colors.white,

      // Menggunakan SafeArea agar konten tidak tertutup status bar
      body: SafeArea(child: bodyContent),

      // LOGIC FAB (Floating Action Button)
      // FAB "Tambah Pesanan" hanya muncul di tab "Pesanan" (index 0).
      // Di tab "List Menu" (index 2), tombol tambahnya sudah ada di dalam file menu_page.dart sendiri.
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
                  onPressed: () {
                    // Aksi tambah pesanan (Placeholder)
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
          : null, // Sembunyikan FAB utama jika bukan di halaman Pesanan
      // CUSTOM NAVBAR
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _bottomNavIndex,
        onItemSelected: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }

  // Widget helper untuk Tab Switch (Aktif/Selesai)
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
