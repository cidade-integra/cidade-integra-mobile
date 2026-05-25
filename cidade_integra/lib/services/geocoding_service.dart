import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Geocodificação via Nominatim (OpenStreetMap).
///
/// Política de uso: 1 req/s, User-Agent identificável e preferência por
/// resultados no Brasil (`countrycodes=br`) para reduzir falsos
/// positivos em logradouros homônimos no exterior.
class GeocodingService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';
  static const _timeout = Duration(seconds: 8);

  Future<({double lat, double lng})?> getCoordinates(String address) async {
    final clean = address.trim();
    if (clean.isEmpty) return null;

    // 1ª tentativa: endereço completo (já normalizado pelo ViaCEP ou
    // digitado pelo usuário).
    final coords = await _query(clean);
    if (coords != null) return coords;

    // Fallback: o Nominatim costuma falhar quando o logradouro tem
    // número faltando ou caracteres ambíguos. Tenta de novo apenas com
    // a parte "Cidade, UF" para pelo menos posicionar o pin na cidade.
    final cityFallback = _extractCityState(clean);
    if (cityFallback != null && cityFallback != clean) {
      return _query(cityFallback);
    }
    return null;
  }

  Future<({double lat, double lng})?> _query(String address) async {
    final uri = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(address)}'
      '&format=json&limit=1'
      '&countrycodes=br'
      '&addressdetails=0'
      '&accept-language=pt-BR',
    );

    try {
      final response = await http
          .get(uri, headers: {'User-Agent': 'CidadeIntegraApp/1.0'})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse('${data[0]['lat']}');
          final lng = double.tryParse('${data[0]['lon']}');
          if (lat != null && lng != null) return (lat: lat, lng: lng);
        }
      } else {
        debugPrint(
          '[Geocoding] HTTP ${response.statusCode} para "$address"',
        );
      }
    } on TimeoutException {
      debugPrint('[Geocoding] timeout para "$address"');
    } catch (e) {
      debugPrint('[Geocoding] erro para "$address": $e');
    }

    return null;
  }

  /// Aceita endereços nos formatos:
  ///   "Rua X, Bairro - Cidade/UF"
  ///   "Rua X, Bairro, Cidade, UF"
  /// e devolve "Cidade, UF" se conseguir identificar.
  String? _extractCityState(String address) {
    final match =
        RegExp(r'([A-Za-zÀ-ÿ\s]+?)\s*[\/,]\s*([A-Z]{2})\b').firstMatch(address);
    if (match == null) return null;
    final city = match.group(1)?.trim();
    final uf = match.group(2)?.trim();
    if (city == null || city.isEmpty || uf == null || uf.length != 2) {
      return null;
    }
    return '$city, $uf, Brasil';
  }
}
