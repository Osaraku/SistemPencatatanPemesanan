import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/menu_service.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final MenuService _menuService = MenuService();
  bool _isLoading = true;

  // Data Statistik
  int _todayIncome = 0;
  int _weeklyIncome = 0;
  List<Order> _weeklyOrders = []; // Transaksi minggu ini

  // Data Grafik (Senin - Minggu)
  List<int> _dailyIncomes = List.filled(
    7,
    0,
  ); // [Sen, Sel, Rab, Kam, Jum, Sab, Min]
  int _maxDailyIncome = 1; // Untuk skala grafik (menghindari pembagian nol)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    List<Order> orders = await _menuService.getOrders();
    _calculateIncome(orders);
    setState(() => _isLoading = false);
  }

  void _calculateIncome(List<Order> orders) {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);

    // Cari hari Senin minggu ini (Start of Week)
    // weekday: 1=Senin, ..., 7=Minggu
    DateTime startOfWeek = todayStart.subtract(Duration(days: now.weekday - 1));

    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    int todayTotal = 0;
    int weekTotal = 0;
    List<int> dailyTotals = List.filled(7, 0);
    List<Order> weekOrdersFiltered = [];

    for (var order in orders) {
      if (!order.isCompleted) continue; // Hanya hitung yang selesai

      try {
        DateTime orderDate = formatter.parse(order.date);

        // Hapus jam/menit untuk perbandingan tanggal
        DateTime dateOnly = DateTime(
          orderDate.year,
          orderDate.month,
          orderDate.day,
        );

        // Cek apakah masuk dalam minggu ini (Senin - sekarang/nanti)
        // Kita hitung selisih hari dari Senin
        int dayDiff = dateOnly.difference(startOfWeek).inDays;

        if (dayDiff >= 0 && dayDiff < 7) {
          // Masuk Minggu Ini
          weekTotal += order.totalPrice;
          weekOrdersFiltered.add(order);

          // Masukkan ke bucket grafik (0=Senin, 6=Minggu)
          dailyTotals[dayDiff] += order.totalPrice;

          // Cek Hari Ini
          if (dateOnly.isAtSameMomentAs(todayStart)) {
            todayTotal += order.totalPrice;
          }
        }
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }

    // Cari nilai tertinggi untuk skala grafik
    int maxVal = dailyTotals.reduce((curr, next) => curr > next ? curr : next);
    if (maxVal == 0) maxVal = 1; // Cegah error pembagian

    setState(() {
      _todayIncome = todayTotal;
      _weeklyIncome = weekTotal;
      _dailyIncomes = dailyTotals;
      _maxDailyIncome = maxVal;
      _weeklyOrders = weekOrdersFiltered; // Simpan untuk list riwayat di bawah
    });
  }

  String formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String formatCompact(int amount) {
    // Format angka pendek untuk grafik (misal 15rb)
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}jt";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}rb";
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FD,
      ), // Background sedikit abu-abu agar card menonjol
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Pendapatan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Pantau performa penjualanmu minggu ini",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // 1. KARTU PENDAPATAN MINGGUAN (Utama)
                    _buildWeeklyCard(),

                    const SizedBox(height: 20),

                    // 2. GRAFIK TREND MINGGUAN
                    _buildChartSection(),

                    const SizedBox(height: 20),

                    // 3. RIWAYAT TRANSAKSI MINGGU INI
                    const Text(
                      "Riwayat Minggu Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _weeklyOrders.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "Belum ada transaksi minggu ini",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap:
                                true, // Agar bisa di dalam SingleChildScrollView
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _weeklyOrders.length,
                            itemBuilder: (context, index) {
                              return _buildTransactionCard(
                                _weeklyOrders[index],
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- WIDGET BAGIAN ATAS (MINGGUAN + HARI INI) ---
  Widget _buildWeeklyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A37C6), Color(0xFF6B5AE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A37C6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Pendapatan Minggu Ini",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            formatRupiah(_weeklyIncome),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Pendapatan Hari Ini (Dalam Card yang sama agar rapi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hari Ini",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      formatRupiah(_todayIncome),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET GRAFIK (CHART) ---
  Widget _buildChartSection() {
    List<String> days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trend Penjualan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // GRAFIK BATANG
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                // Hitung tinggi batang (relatif terhadap max income)
                double percentage = _dailyIncomes[index] / _maxDailyIncome;
                // Pastikan minimal ada tinggi sedikit supaya bar terlihat walau 0
                if (percentage == 0) percentage = 0.02;

                bool isToday = (DateTime.now().weekday - 1) == index;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Label Nilai di atas bar (opsional, tampil jika ada nilai)
                    if (_dailyIncomes[index] > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          formatCompact(_dailyIncomes[index]),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    // Batang Grafik
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 20, // Lebar batang
                      height: 100 * percentage, // Tinggi maksimal 100 pixel
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF4A37C6)
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Label Hari
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday ? const Color(0xFF4A37C6) : Colors.grey,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET ITEM LIST RIWAYAT ---
  Widget _buildTransactionCard(Order order) {
    final firstName = order.items.isNotEmpty
        ? order.items.first['name']
        : 'Pesanan';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName +
                      (order.items.length > 1
                          ? " +${order.items.length - 1} lainnya"
                          : ""),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  order.date,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(order.totalPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A37C6),
            ),
          ),
        ],
      ),
    );
  }
}
