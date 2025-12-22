import 'dart:io';
import 'package:flutter/material.dart';
import 'services/menu_service.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuItem menu;

  const MenuDetailPage({super.key, required this.menu});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  // State untuk Opsi
  String _levelPedas = "Tidak Pedas";
  String _jenisTelur = "Tanpa Telur";
  String _tipePesanan = "Makan di Tempat";
  String _tipePembayaran = "Tunai";
  int _qty = 1;

  // Pilihan Opsi
  final List<String> _listPedas = [
    "Tidak Pedas",
    "Sedikit",
    "Sedang",
    "Sangat Pedas",
  ];
  final List<String> _listTelur = ["Tanpa Telur", "Ceplok", "Dadar", "Rebus"];
  final List<String> _listTipe = ["Makan di Tempat", "Bungkus"];
  final List<String> _listBayar = ["Tunai", "QRIS"];

  // Helper Gambar
  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.fastfood, size: 50, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    }
  }

  void _saveOrder() {
    // Kembalikan data lengkap ke halaman sebelumnya
    Map<String, dynamic> orderItem = {
      'menu': widget.menu, // Object Menu Asli
      'qty': _qty,
      'options': {
        'level': _levelPedas,
        'egg': _jenisTelur,
        'type': _tipePesanan,
        'payment': _tipePembayaran,
      },
    };
    Navigator.pop(context, orderItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Produk
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: _buildImage(widget.menu.imagePath),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.menu.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Rp ${widget.menu.price}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4A37C6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Divider(height: 30),

                  // 1. Level Pedas
                  _buildSectionTitle("Level Pedas"),
                  Wrap(
                    spacing: 8,
                    children: _listPedas
                        .map(
                          (level) => ChoiceChip(
                            label: Text(level),
                            selected: _levelPedas == level,
                            selectedColor: const Color(
                              0xFF4A37C6,
                            ).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _levelPedas == level
                                  ? const Color(0xFF4A37C6)
                                  : Colors.black,
                            ),
                            onSelected: (val) =>
                                setState(() => _levelPedas = level),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // 2. Jenis Telur
                  _buildSectionTitle("Jenis Telur"),
                  Wrap(
                    spacing: 8,
                    children: _listTelur
                        .map(
                          (egg) => ChoiceChip(
                            label: Text(egg),
                            selected: _jenisTelur == egg,
                            selectedColor: const Color(
                              0xFF4A37C6,
                            ).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _jenisTelur == egg
                                  ? const Color(0xFF4A37C6)
                                  : Colors.black,
                            ),
                            onSelected: (val) =>
                                setState(() => _jenisTelur = egg),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // 3. Tipe Pemesanan & Pembayaran (Row)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Tipe Pesanan"),
                            DropdownButtonFormField<String>(
                              initialValue: _tipePesanan,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: _listTipe
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _tipePesanan = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Pembayaran"),
                            DropdownButtonFormField<String>(
                              initialValue: _tipePembayaran,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: _listBayar
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _tipePembayaran = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM BAR (Counter + Button)
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
                children: [
                  // Counter Qty
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () =>
                              setState(() => _qty = (_qty > 1) ? _qty - 1 : 1),
                        ),
                        Text(
                          _qty.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _qty++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Tombol Tambah
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A37C6),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveOrder,
                      child: Text(
                        "Tambah - Rp ${widget.menu.price * _qty}",
                        style: const TextStyle(
                          color: Colors.white,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
