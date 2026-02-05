import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  static List<Map<String, dynamic>> getTringoShops(LatLng center) {
    return [
      {
        'id': 'shop1',
        'name': 'Ravi Dial Shop',
        'address': 'Anna Nagar, Chennai - 5km',
        'phone': '+919876543210',
        'lat': center.latitude + 0.002,
        'lng': center.longitude + 0.001,
        'distance': 250,
      },
      {
        'id': 'shop2',
        'name': 'Priya Mobile Shop',
        'address': 'Nungambakkam, Chennai - 3km',
        'phone': '+918765432109',
        'lat': center.latitude - 0.0015,
        'lng': center.longitude + 0.002,
        'distance': 450,
      },
      {
        'id': 'shop3',
        'name': 'Kumar Recharge Point',
        'address': 'T. Nagar, Chennai - 2km',
        'phone': '+917654321098',
        'lat': center.latitude + 0.003,
        'lng': center.longitude - 0.001,
        'distance': 320,
      },
      {
        'id': 'shop4',
        'name': 'Suresh Dial Center',
        'address': 'Velachery, Chennai - 4km',
        'phone': '+919123456789',
        'lat': center.latitude - 0.002,
        'lng': center.longitude - 0.003,
        'distance': 380,
      },
    ];
  }
}
