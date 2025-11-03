import 'package:flutter/material.dart';
import 'package:nashwaluthfiya_124230016_pam_a/controllers/inventory_controller.dart';
import 'package:nashwaluthfiya_124230016_pam_a/menu/login_page.dart';
import 'package:nashwaluthfiya_124230016_pam_a/models/inventory_models.dart';
import 'package:nashwaluthfiya_124230016_pam_a/menu/detail_page.dart';
import 'package:nashwaluthfiya_124230016_pam_a/menu/add_edit_page.dart';
import 'package:nashwaluthfiya_124230016_pam_a/menu/profile_page.dart';
// import 'package:nashwaluthfiya_124230016_pam_a/menu/feedback_page.dart';
import 'package:nashwaluthfiya_124230016_pam_a/controllers/auth_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthController();
  final _inv = InventoryController();

  List<InventoryItem> _items = [];
  String _search = "";
  String _category = "Semua Kategori";

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadItems();
  }

  void _checkSession() {
    if (_auth.getSession() == null) {
      // kalau tidak ada session, paksa kembali ke login
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
    }
  }

  void _loadItems() async {
    final data = await _inv.getAllItems();
    setState(() => _items = data);
  }

  List<InventoryItem> get _filteredItems {
    return _items.where((item) {
      final matchText = item.name.toLowerCase().contains(_search.toLowerCase());
      final matchCategory =
          _category == "Semua Kategori" || item.category == _category;
      return matchText && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text("StokMate"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 12),
            _categoryFilter(),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(child: Text("Belum ada data barang"))
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (_, i) {
                        final item = _filteredItems[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                "Kategori: ${item.category}\nQty: ${item.quantity} ${item.unit}"),
                            trailing: Text(
                              "Rp ${item.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailItemPage(item: item),
                                ),
                              );
                              _loadItems(); // refresh setelah edit/delete
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ✅ Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2E7D32),
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Tambah"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        onTap: (i) {
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditPage()),
            ).then((_) => _loadItems());
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (v) => setState(() => _search = v),
      decoration: InputDecoration(
        hintText: "Cari barang...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
        filled: true,
        fillColor: Colors.white,
        border: _border(),
        focusedBorder: _border(focused: true),
      ),
    );
  }

  Widget _categoryFilter() {
    final categories = [
      "Semua Kategori",
      "Dapur",
      "Kamar Mandi",
      "Kebersihan",
      "Elektronik",
      "Obat & Kesehatan",
      "Alat Tulis",
      "Lainnya"
    ];

    return DropdownButtonFormField<String>(
      initialValue: _category,
      items: categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _category = v!),
      decoration: InputDecoration(
        border: _border(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  OutlineInputBorder _border({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: focused ? const Color(0xFF4CAF50) : const Color(0xFFC8E6C9),
        width: focused ? 2 : 1,
      ),
    );
  }
}