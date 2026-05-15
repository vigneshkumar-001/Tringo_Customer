import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/logout_response.dart';

class LogoutRepository {
  final ApiDataSource api;

  const LogoutRepository(this.api);

  Future<void> logoutRemote({
    required String refreshToken,
    String? sessionToken,
  }) async {
    final rt = refreshToken.trim();
    if (rt.isEmpty) return;

    // Fire-and-forget friendly: caller decides whether to await.
    await api.logout(
      request: LogoutRequest(
        refreshToken: rt,
        sessionToken: (sessionToken ?? '').trim().isEmpty ? null : sessionToken,
      ),
    );
  }
}

