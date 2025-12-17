import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Model Data Menu (Tetap sama)
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

class MenuService {
  static const String _keyMenus = 'menus_data';

  // DATA AWAL DIPERBARUI: Sesuaikan dengan nama file di folder assets/images/
  final List<MenuItem> _initialMenus = [
    // Nasi Goreng
    MenuItem(
      name: "Nasi Goreng Ori",
      category: "Nasi Goreng",
      price: 15000,
      imagePath: "assets/images/Nasi-Goreng-original.jpg", //
    ),
    MenuItem(
      name: "Nasi Goreng Ayam",
      category: "Nasi Goreng",
      price: 18000,
      imagePath: "assets/images/Nasi-Goreng-ayam.jpg", //
    ),
    MenuItem(
      name: "Nasi Goreng Cikur",
      category: "Nasi Goreng",
      price: 15000,
      imagePath: "assets/images/Nasi-Goreng-cikur.jpg", //
    ),
    MenuItem(
      name: "Nasi Goreng Rendang",
      category: "Nasi Goreng",
      price: 17000,
      imagePath: "assets/images/Nasi-Goreng-rendang.jpg", //
    ),

    // Kwetiaw
    MenuItem(
      name: "Kwetiaw Goreng",
      category: "Kwetiaw",
      price: 17000,
      imagePath: "assets/images/kwetiau-goreng.jpg", //
    ),
    MenuItem(
      name: "Kwetiaw Kuah",
      category: "Kwetiaw",
      price: 17000,
      imagePath: "assets/images/kwetiau-kuah.jpeg", //
    ),

    // Mie
    MenuItem(
      name: "Mie Goreng",
      category: "Mie",
      price: 15000,
      imagePath: "assets/images/mie-goreng.jpeg", //
    ),
    MenuItem(
      name: "Mie Tek Tek",
      category: "Mie",
      price: 15000,
      imagePath: "assets/images/mie-tektek.jpeg", //
    ),

    // Spicy Tofu
    MenuItem(
      name: "Spicy Tofu Original",
      category: "Spicy Tofu",
      price: 12000,
      imagePath: "assets/images/spicy-tofu-ori.jpg", //
    ),
    MenuItem(
      name: "Spicy Tofu Dabu",
      category: "Spicy Tofu",
      price: 15000,
      imagePath: "assets/images/spicy-tofu-dabu.jpg", //
    ),
  ];

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
}
