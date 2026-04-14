import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  Future<({double lat, double lng})?> getCoordinates(String address) async {
    if (address.trim().isEmpty) return null;

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(address)}'
      '&format=json&limit=1',
    );

    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'CidadeIntegraApp/1.0',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return (
            lat: double.parse(data[0]['lat']),
            lng: double.parse(data[0]['lon']),
          );
        }
      }
    } catch (_) {}

    return null;
  }
}
