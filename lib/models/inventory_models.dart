

class InventoryItem {
  // Atribut data barang (ID null saat item baru dibuat)
  String? id;
  String name;
  String category;
  int quantity;
  String unit;
  double price;
  String currency; // Mata uang dasar (misal: IDR)
  DateTime expiryDate;
  String location; // Nama toko/tempat pembelian (LBS)
  double latitude;  // Koordinat LBS
  double longitude; // Koordinat LBS

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.currency,
    required this.expiryDate,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  // Metode untuk konversi Model ke Map (untuk disimpan ke Hive Box)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'currency': currency,
      // Simpan DateTime sebagai ISO String agar mudah disimpan di Hive
      'expiryDate': expiryDate.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Factory constructor untuk konversi dari Map (data dari Hive) ke Model
  factory InventoryItem.fromMap(Map<dynamic, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String?,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int,
      unit: map['unit'] as String,
      price: map['price'] as double,
      currency: map['currency'] as String,
      // Konversi ISO String kembali ke DateTime
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      location: map['location'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
}