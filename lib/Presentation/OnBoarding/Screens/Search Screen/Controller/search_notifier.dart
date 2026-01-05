import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Search%20Screen/Model/search_suggestion_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class SearchState {
  final bool isLoading;
  final String? error;
  final SearchSuggestionResponse? searchSuggestionResponse;
  final List<SearchItem> recentItems;

  const SearchState({
    this.isLoading = false,
    this.error,
    this.recentItems = const [],
    this.searchSuggestionResponse,
  });

  factory SearchState.initial() => const SearchState();

  SearchState copyWith({
    bool? isLoading,
    String? error,
    SearchSuggestionResponse? searchSuggestionResponse,
    List<SearchItem>? recentItems,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchSuggestionResponse: searchSuggestionResponse,
      recentItems: recentItems ?? this.recentItems,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  late final ApiDataSource api;

  Timer? _debounce;
  int _requestSeq = 0;

  @override
  SearchState build() {
    api = ref.read(apiDataSourceProvider);
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return SearchState.initial();
  }

  bool _isDigitsOnly(String s) => RegExp(r'^\d+$').hasMatch(s);

  /// Call this from UI on each key press
  void onQueryChanged(String raw) {
    final q = raw.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(q);
    });
  }

  Future<void> _runSearch(String q) async {
    // Empty -> clear results
    if (q.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: null,
        searchSuggestionResponse: null,
      );
      return;
    }

    final isPhoneTyping = _isDigitsOnly(q);

    // ✅ Phone rule: ONLY search when exactly 10 digits
    if (isPhoneTyping && q.length != 10) {
      // Don’t call API for 1..9 digits (avoid SERVICE_SHOP mixed response)
      state = state.copyWith(
        isLoading: false,
        error: null,
        searchSuggestionResponse: null,
      );
      return;
    }

    final int mySeq = ++_requestSeq;

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchSuggestionResponse: null,
    );

    final result = await api.searchSuggestions(searchWords: q, query: q);

    // Ignore stale results (race condition fix)
    if (mySeq != _requestSeq) return;

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
          searchSuggestionResponse: null,
        );
      },
          (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          searchSuggestionResponse: response,
        );
      },
    );
  }

  void addRecentItem(SearchItem item) {
    final current = List<SearchItem>.from(state.recentItems);

    current.removeWhere((e) => e.id == item.id && e.type == item.type);
    current.insert(0, item);

    if (current.length > 10) current.removeLast();

    state = state.copyWith(recentItems: current);
  }

  void removeRecentItem(SearchItem item) {
    final current = List<SearchItem>.from(state.recentItems);
    current.removeWhere((e) => e.id == item.id && e.type == item.type);
    state = state.copyWith(recentItems: current);
  }

  void clearResults() {
    state = state.copyWith(
      isLoading: false,
      error: null,
      searchSuggestionResponse: null,
    );
  }
}

final searchNotifierProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);


///old///
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tringo_app/Api/DataSource/api_data_source.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Controller/login_notifier.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Search%20Screen/Model/search_suggestion_response.dart';
//
// class SearchState {
//   final bool isLoading;
//   final String? error;
//   final SearchSuggestionResponse? searchSuggestionResponse;
//   final List<SearchItem> recentItems;
//
//   const SearchState({
//     this.isLoading = false,
//     this.error,
//     this.recentItems = const [],
//     this.searchSuggestionResponse,
//   });
//   factory SearchState.initial() => const SearchState();
//   SearchState copyWith({
//     bool? isLoading,
//     String? error,
//     SearchSuggestionResponse? searchSuggestionResponse,
//     List<SearchItem>? recentItems,
//   }) {
//     return SearchState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//       searchSuggestionResponse:
//           searchSuggestionResponse ?? this.searchSuggestionResponse,
//
//       recentItems: recentItems ?? this.recentItems,
//     );
//   }
// }
//
// class SearchNotifier extends Notifier<SearchState> {
//   late final ApiDataSource api;
//
//   @override
//   SearchState build() {
//     api = ref.read(apiDataSourceProvider);
//     return SearchState.initial();
//   }
//
//   Future<void> searchSuggestion({
//     required String searchWords,
//     required String query,
//     bool force = false,
//   }) async {
//     state = state.copyWith(isLoading: true, searchSuggestionResponse: null);
//
//     final result = await api.searchSuggestions(
//       searchWords: searchWords,
//       query: query,
//     );
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           searchSuggestionResponse: null,
//         );
//       },
//       (response) {
//         state = state.copyWith(
//           isLoading: false,
//           searchSuggestionResponse: response,
//         );
//       },
//     );
//   }
//
//   void addRecentItem(SearchItem item) {
//     final current = List<SearchItem>.from(state.recentItems);
//
//     current.removeWhere((e) => e.id == item.id && e.type == item.type);
//
//     current.insert(0, item);
//
//     if (current.length > 10) current.removeLast();
//
//     state = state.copyWith(recentItems: current);
//   }
//
//   void removeRecentItem(SearchItem item) {
//     final current = List<SearchItem>.from(state.recentItems);
//     current.removeWhere((e) => e.id == item.id && e.type == item.type);
//     state = state.copyWith(recentItems: current);
//   }
// }
//
// final searchNotifierProvider = NotifierProvider<SearchNotifier, SearchState>(
//   SearchNotifier.new,
// );
