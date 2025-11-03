import 'dart:async'; 
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo; 
import 'package:flutter/foundation.dart'; 

class LocationService {
  
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // 1. Cek Layanan Aktif
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LBS: Layanan lokasi tidak aktif.');
        return null;
      }

      // 2. Cek dan Minta Izin
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          debugPrint('LBS: Izin lokasi ditolak atau ditolak permanen.');
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // 💡 Ganti dari HIGH ke MEDIUM
        timeLimit: const Duration(seconds: 10) 
      );
      return position;
      
    } on TimeoutException {
      debugPrint('LBS: Gagal mengambil posisi: Timeout (Sinyal GPS lambat).');
      return null;
    } catch (e) {
      debugPrint('LBS: Gagal mengambil posisi: $e');
      return null;
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    final coordinateFallback = 'Lat ${lat.toStringAsFixed(4)}, Lon ${lon.toStringAsFixed(4)} (Gagal Geocoding)';

    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, lon)
          .timeout(const Duration(seconds: 5)); 
          
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String address = [p.name, p.thoroughfare, p.subLocality, p.locality]
            .where((element) => element != null && element.isNotEmpty)
            .join(', ');
            
        return address.isEmpty ? 'Lokasi di Koordinat: $coordinateFallback' : address; 
      }
      
      return 'Koordinat Tersimpan (Nama Lokasi Kosong)';

    } catch (e) {
      debugPrint('LBS Error Reverse Geocoding: $e'); 
      return 'Lokasi di Koordinat: $coordinateFallback';
    }
  }
}