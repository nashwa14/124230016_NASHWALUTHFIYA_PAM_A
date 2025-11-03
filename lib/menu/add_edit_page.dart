import 'package:flutter/material.dart';
import '../controllers/inventory_controller.dart';
import '../services/location_service.dart';
import '../models/inventory_models.dart';

class AddEditPage extends StatefulWidget {
  final InventoryItem? itemToEdit;
  const AddEditPage({super.key, this.itemToEdit});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  // Inisialisasi Controller/Service
  final _controller = InventoryController();
  final _locationService = LocationService();
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _price = TextEditingController();

  String? _selectedCategory;
  String _selectedUnit = 'pcs';
  String _selectedCurrency = 'IDR';

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  String _locationName = 'Lokasi belum diambil/dipilih';
  double _lat = 0.0;
  double _lon = 0.0;

  bool _loading = false;

  final List<String> _categories = [
    "Bahan Makanan",
    "Minuman",
    "Produk Segar",
    "Perawatan Diri",
    "Kebersihan",
    "ATK",
    "Lainnya",
  ];
  final List<String> _units = [
    'pcs',
    'botol',
    'kg',
    'buah',
    'liter',
    'mililiter',
    'pak, roll',
  ];
  final List<String> _currencies = ['IDR', 'USD', 'EUR, JPY'];

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _initializeEditMode(widget.itemToEdit!);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  void _initializeEditMode(InventoryItem item) {
    _name.text = item.name;
    _quantity.text = item.quantity.toString();
    _price.text = item.price.toStringAsFixed(0);
    _selectedCategory = item.category;
    _selectedUnit = item.unit;
    _selectedCurrency = item.currency;
    _expiryDate = item.expiryDate;
    _locationName = item.location;
    _lat = item.latitude;
    _lon = item.longitude;
  }

  /// --- LOGIC LBS ---
  Future<void> _getCurrentLocation({bool showMsg = true}) async {
    setState(() => _loading = true); // Tetap aktifkan loading di awal

    final position = await _locationService.getCurrentLocation();

    if (!mounted) {
      setState(
        () => _loading = false,
      ); // Pastikan loading dimatikan jika widget sudah dicopot
      return;
    }

    if (position != null) {
      // Lokasi berhasil diambil, sekarang lakukan Reverse Geocoding
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        setState(
          () => _loading = false,
        ); // Pastikan loading dimatikan jika widget sudah dicopot
        return;
      }

      setState(() {
        _locationName = address;
        _lat = position.latitude;
        _lon = position.longitude;
      });
      if (showMsg) _msg('Lokasi berhasil diambil: $address', true);
    } else {
      if (showMsg)
        _msg(
          'Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin diberikan.',
          false,
        );
    }

    // ✅ PENTING: Pindahkan setState(() => _loading = false) ke akhir fungsi
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  // --- DATE PICKER ---
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _expiryDate) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _onSaveItem() async {
    if (!_formKey.currentState!.validate()) {
      _msg('Harap lengkapi semua field yang wajib diisi.', false);
      return;
    }

    if (_lat == 0.0 && _lon == 0.0) {
      _msg('Harap ambil lokasi pembelian terlebih dahulu!', false);
      return;
    }

    setState(() => _loading = true);
    print('DEBUG: Mulai simpan item...');

    try {
      final newItem = InventoryItem(
        id: widget.itemToEdit?.id,
        name: _name.text.trim(),
        category: _selectedCategory!,
        quantity: int.parse(_quantity.text),
        unit: _selectedUnit,
        price: double.parse(_price.text),
        currency: _selectedCurrency,
        expiryDate: _expiryDate,
        location: _locationName,
        latitude: _lat,
        longitude: _lon,
      );

      await _controller.saveItem(newItem);
      print('DEBUG: Item berhasil disimpan.');

      if (!mounted) return;
      final action = widget.itemToEdit == null ? 'ditambahkan' : 'diperbarui';
      _msg('Item berhasil $action!', true);

      Navigator.pop(context, true);
    } catch (e, s) {
      print('❌ Error saat simpan item: $e');
      print(s);
      if (mounted) _msg('Gagal menyimpan item. Coba lagi.', false);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        print('DEBUG: Loading dimatikan');
      }
    }
  }

  void _msg(String msg, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  // --- Build Widget (Implementasi UI Gaya Baru) ---

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // 1. Header Gradien
          Container(
            height: 1000,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Edit Item' : 'Tambah Item Stok',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content Form (Card Putih)
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0, // Memastikan area scroll memanjang ke bawah
            child: SingleChildScrollView(
              // <<< PERUBAHAN KRITIS: Tambahkan padding bawah yang cukup besar
              padding: const EdgeInsets.only(
                left: 25.0,
                right: 25.0,
                bottom: 150,
              ),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // --- NAMA BARANG ---
                      _buildLabel('Nama Barang'),
                      _buildCustomTextField(
                        _name,
                        'masukkan barangnya',
                        Icons.inventory_2,
                      ),
                      const Divider(height: 30),

                      // --- KATEGORI BARANG ---
                      _buildLabel('Kategori Barang'),
                      _buildCategoryDropdown(),
                      const Divider(height: 30),

                      // --- JUMLAH & SATUAN (Side by Side) ---
                      _buildLabel('Jumlah & Satuan'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCustomTextField(
                              _quantity,
                              '',
                              Icons.numbers,
                              isNumeric: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildUnitDropdown()),
                        ],
                      ),
                      const Divider(height: 30),

                      // --- HARGA & MATA UANG ---
                      _buildLabel('Harga Beli & Mata Uang'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCustomTextField(
                              _price,
                              '',
                              Icons.attach_money,
                              isNumeric: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCurrencyDropdown()),
                        ],
                      ),
                      const Divider(height: 30),

                      // --- TANGGAL KADALUARSA ---
                      _buildLabel('Tanggal Kadaluarsa'),
                      _buildDateDisplay(),
                      const Divider(height: 30),

                      // --- LOKASI PEMBELIAN (LBS) ---
                      _buildLabel('Lokasi Pembelian'),
                      _buildLocationMapPlaceholder(),
                      const SizedBox(height: 10),
                      _buildLocationButton(),
                      const SizedBox(height: 30),

                      // --- TOMBOL SIMPAN ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _onSaveItem,
                          icon: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH BARANG',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF689F38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCustomTextField(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: Colors.green),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Wajib diisi';
        if (isNumeric && double.tryParse(value) == null) return 'Harus angka';
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
      items: _categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
      validator: (v) => v == null ? 'Pilih kategori' : null,
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedUnit,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
      items: _units
          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
          .toList(),
      onChanged: (v) => setState(() => _selectedUnit = v!),
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCurrency,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
      items: _currencies
          .map((curr) => DropdownMenuItem(value: curr, child: Text(curr)))
          .toList(),
      onChanged: (v) => setState(() => _selectedCurrency = v!),
    );
  }

  Widget _buildDateDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_expiryDate.day} ${_getMonthName(_expiryDate.month)} ${_expiryDate.year}',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar, color: Colors.green),
            onPressed: _selectDate,
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return names[month - 1];
  }

  Widget _buildLocationMapPlaceholder() {
    final bool locationValid = _lat != 0.0 || _lon != 0.0;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              locationValid ? Icons.check_circle : Icons.location_on,
              size: 40,
              color: locationValid ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            Text(
              _locationName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: locationValid ? Colors.green[800] : Colors.red,
              ),
            ),
            if (locationValid)
              Text(
                'Lat: ${_lat.toStringAsFixed(4)}, Lon: ${_lon.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : () => _getCurrentLocation(showMsg: true),
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.gps_fixed, color: Colors.white),
        label: Text(
          _loading ? 'Mengambil Lokasi...' : 'Ambil Lokasi Sekarang',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
