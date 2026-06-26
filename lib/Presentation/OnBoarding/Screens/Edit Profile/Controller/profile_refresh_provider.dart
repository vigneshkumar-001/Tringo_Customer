import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state++;
  }
}

final profileRefreshProvider =
    NotifierProvider<ProfileRefreshNotifier, int>(ProfileRefreshNotifier.new);
