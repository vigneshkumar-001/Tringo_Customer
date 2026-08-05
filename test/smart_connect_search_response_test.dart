import 'package:flutter_test/flutter_test.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Model/smart_connect_search_response.dart';

void main() {
  group('SmartConnectSearchItem category display', () {
    test(
      'uses the API category for the Create Smart Connect Product field',
      () {
        final item = SmartConnectSearchItem.fromJson({
          'listingId': 'listing-1',
          'listingType': 'PRODUCT',
          'shopId': 'shop-1',
          'primaryText': 'Ceiling Fan',
          'secondaryText': 'in Product',
          'category': 'Electricals',
        });

        expect(item.categoryDisplayText, 'Electricals');
      },
    );

    test('falls back to primary text when an older API omits category', () {
      final item = SmartConnectSearchItem.fromJson({
        'listingId': 'listing-1',
        'listingType': 'PRODUCT',
        'shopId': 'shop-1',
        'primaryText': 'Ceiling Fan',
        'secondaryText': 'in Product',
      });

      expect(item.categoryDisplayText, 'Ceiling Fan');
    });
  });
}
