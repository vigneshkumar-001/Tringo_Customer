import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';

final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

