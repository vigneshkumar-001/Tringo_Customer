import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Api/Repository/logout_repository.dart';

final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

final logoutRepositoryProvider = Provider<LogoutRepository>((ref) {
  return LogoutRepository(ref.read(apiDataSourceProvider));
});

