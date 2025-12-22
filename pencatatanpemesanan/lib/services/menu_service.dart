import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// --- MODEL DATA ---
class MenuItem {
  final String name;
  final String category;
  final int price;
  final String imagePath;

  MenuItem({
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'price': price,
    'imagePath': imagePath,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    name: json['name'],
    category: json['category'],
    price: json['price'],
    imagePath: json['imagePath'],
  );
}

class Order {
  final String id;
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final String date; // Format: yyyy-MM-dd HH:mm
  bool isCompleted;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items,
    'totalPrice': totalPrice,
    'date': date,
    'isCompleted': isCompleted,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    items: List<Map<String, dynamic>>.from(json['items']),
    totalPrice: json['totalPrice'],
    date: json['date'],
    isCompleted: json['isCompleted'],
  );
}

// --- SERVICE ---
class MenuService {
  static const String _keyMenus = 'menus_data';
  static const String _keyOrders = 'orders_data';

  // Tambahkan di dalam class MenuService
  static const String _keyCategories = 'categories_data';
  final List<String> _initialCategories = [
    "Nasi Goreng",
    "Nasi Gila",
    "Kwetiaw",
    "Mie",
    "Spicy Tofu",
    "Minuman",
  ];

  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? catsString = prefs.getString(_keyCategories);
    if (catsString != null) {
      return List<String>.from(jsonDecode(catsString));
    } else {
      await saveCategories(_initialCategories);
      return _initialCategories;
    }
  }

  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCategories, jsonEncode(categories));
  }

  Future<void> addCategory(String category) async {
    List<String> current = await getCategories();
    if (!current.contains(category)) {
      current.add(category);
      await saveCategories(current);
    }
  }

  // Data Awal (Seed Data)
  final List<MenuItem> _initialMenus = [
    MenuItem(
      name: "Nasi Goreng Ori",
      category: "Nasi Goreng",
      price: 15000,
      imagePath: "assets/images/Nasi-Goreng-original.jpg",
    ),
    MenuItem(
      name: "Nasi Goreng Ayam",
      category: "Nasi Goreng",
      price: 18000,
      imagePath: "assets/images/Nasi-Goreng-ayam.jpg",
    ),
    MenuItem(
      name: "Nasi Goreng Cikur",
      category: "Nasi Goreng",
      price: 15000,
      imagePath: "assets/images/Nasi-Goreng-cikur.jpg",
    ),
    MenuItem(
      name: "Nasi Goreng Kulit",
      category: "Nasi Goreng",
      price: 17000,
      imagePath: "assets/images/nasi-goreng-kulit.jpg",
    ),
    MenuItem(
      name: "Nasi Goreng Rendang",
      category: "Nasi Goreng",
      price: 17000,
      imagePath: "assets/images/Nasi-Goreng-rendang.jpg",
    ),
    MenuItem(
      name: "Nasi Gila Ori",
      category: "Nasi Gila",
      price: 15000,
      imagePath: "assets/images/nasi-gila-ori.jpg",
    ),
    MenuItem(
      name: "Nasi Gila Ayam",
      category: "Nasi Gila",
      price: 18000,
      imagePath: "assets/images/nasi-gila-ayam.jpg",
    ),
    MenuItem(
      name: "Nasi Gila Dabu Dabu",
      category: "Nasi Gila",
      price: 17000,
      imagePath: "assets/images/nasi-gila-dabudabu.jpg",
    ),
    MenuItem(
      name: "Nasi Gila Telur",
      category: "Nasi Gila",
      price: 17000,
      imagePath: "assets/images/nasi-gila-telur.jpg",
    ),
    MenuItem(
      name: "Nasi Gila Telur Puyuh",
      category: "Nasi Gila",
      price: 17000,
      imagePath: "assets/images/nasi-gila-telurpuyuh.jpg",
    ),
    MenuItem(
      name: "Nasi Gila Keju",
      category: "Nasi Gila",
      price: 17000,
      imagePath: "assets/images/nasi-gila-keju.jpg",
    ),
    MenuItem(
      name: "Kwetiaw Goreng",
      category: "Kwetiaw",
      price: 17000,
      imagePath: "assets/images/kwetiau-goreng.jpg",
    ),
    MenuItem(
      name: "Kwetiaw Kuah",
      category: "Kwetiaw",
      price: 17000,
      imagePath: "assets/images/kwetiau-kuah.jpeg",
    ),
    MenuItem(
      name: "Mie Goreng",
      category: "Mie",
      price: 15000,
      imagePath: "assets/images/mie-goreng.jpeg",
    ),
    MenuItem(
      name: "Mie Tek Tek",
      category: "Mie",
      price: 15000,
      imagePath: "assets/images/mie-tektek.jpeg",
    ),
    MenuItem(
      name: "Spicy Tofu Original",
      category: "Spicy Tofu",
      price: 12000,
      imagePath: "assets/images/spicy-tofu-ori.jpg",
    ),
    MenuItem(
      name: "Spicy Tofu Dabu",
      category: "Spicy Tofu",
      price: 15000,
      imagePath: "assets/images/spicy-tofu-dabu.jpg",
    ),
  ];

  // --- MENU METHODS ---
  Future<List<MenuItem>> getMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? menusString = prefs.getString(_keyMenus);
    if (menusString != null) {
      List<dynamic> jsonList = jsonDecode(menusString);
      return jsonList.map((json) => MenuItem.fromJson(json)).toList();
    } else {
      await saveMenus(_initialMenus);
      return _initialMenus;
    }
  }

  Future<void> saveMenus(List<MenuItem> menus) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(menus.map((m) => m.toJson()).toList());
    await prefs.setString(_keyMenus, jsonString);
  }

  Future<void> addMenu(MenuItem newMenu) async {
    List<MenuItem> currentMenus = await getMenus();
    currentMenus.add(newMenu);
    await saveMenus(currentMenus);
  }

  Future<void> deleteMenu(MenuItem target) async {
    List<MenuItem> currentMenus = await getMenus();
    currentMenus.removeWhere(
      (item) =>
          item.name == target.name &&
          item.category == target.category &&
          item.price == target.price,
    );
    await saveMenus(currentMenus);
  }

  Future<void> updateMenu(MenuItem oldItem, MenuItem newItem) async {
    List<MenuItem> currentMenus = await getMenus();
    int index = currentMenus.indexWhere(
      (item) =>
          item.name == oldItem.name &&
          item.category == oldItem.category &&
          item.price == oldItem.price,
    );
    if (index != -1) {
      currentMenus[index] = newItem;
      await saveMenus(currentMenus);
    }
  }

  // --- ORDER METHODS ---
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersString = prefs.getString(_keyOrders);

    if (ordersString != null) {
      List<dynamic> jsonList = jsonDecode(ordersString);
      return jsonList.map((json) => Order.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> addOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil raw list (tanpa manipulasi order)
    final String? ordersString = prefs.getString(_keyOrders);
    List<Order> currentOrders = [];
    if (ordersString != null) {
      List<dynamic> jsonList = jsonDecode(ordersString);
      currentOrders = jsonList.map((json) => Order.fromJson(json)).toList();
    }

    currentOrders.add(order);

    String jsonString = jsonEncode(
      currentOrders.map((o) => o.toJson()).toList(),
    );
    await prefs.setString(_keyOrders, jsonString);
  }

  Future<void> deleteOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersString = prefs.getString(_keyOrders);
    if (ordersString == null) return;

    List<Order> currentOrders = (jsonDecode(ordersString) as List)
        .map((json) => Order.fromJson(json))
        .toList();

    // Hapus pesanan berdasarkan ID
    currentOrders.removeWhere((o) => o.id == orderId);

    await prefs.setString(
      _keyOrders,
      jsonEncode(currentOrders.map((o) => o.toJson()).toList()),
    );
  }

  Future<void> completeOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersString = prefs.getString(_keyOrders);
    if (ordersString == null) return;

    List<Order> currentOrders = (jsonDecode(ordersString) as List)
        .map((json) => Order.fromJson(json))
        .toList();
    int index = currentOrders.indexWhere((o) => o.id == orderId);

    if (index != -1) {
      currentOrders[index].isCompleted = true;
      await prefs.setString(
        _keyOrders,
        jsonEncode(currentOrders.map((o) => o.toJson()).toList()),
      );
    }
  }

  // --- FUNGSI HITUNG PENDAPATAN ---
  Future<Map<String, int>> getIncomeStats() async {
    List<Order> allOrders = await getOrders();

    int todayIncome = 0;
    int weeklyIncome = 0;

    DateTime now = DateTime.now();
    // Cari tanggal hari Senin minggu ini (Start of Week)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Reset jam ke 00:00:00
    startOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    DateTime todayStart = DateTime(now.year, now.month, now.day);

    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    for (var order in allOrders) {
      try {
        DateTime orderDate = formatter.parse(order.date);

        // Cek Hari Ini
        if (orderDate.year == now.year &&
            orderDate.month == now.month &&
            orderDate.day == now.day) {
          todayIncome += order.totalPrice;
        }

        // Cek Minggu Ini (Dari Senin - Sekarang)
        // Jika orderDate >= startOfWeek
        if (orderDate.isAfter(startOfWeek) ||
            orderDate.isAtSameMomentAs(startOfWeek)) {
          weeklyIncome += order.totalPrice;
        }
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    return {'today': todayIncome, 'week': weeklyIncome};
  }
}
