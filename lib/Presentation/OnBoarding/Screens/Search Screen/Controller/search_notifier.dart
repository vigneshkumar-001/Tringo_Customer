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

  static const Set<String> _mobileTypes = {
    'OWNER_SHOP',
    'CUSTOMER',
    'VENDOR',
    'EMPLOYEE',
  };

  @override
  SearchState build() {
    api = ref.read(apiDataSourceProvider);
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return SearchState.initial();
  }

  bool _isDigitsOnly(String s) => RegExp(r'^\d+$').hasMatch(s);
  bool _isMobileNumber(String q) => _isDigitsOnly(q) && q.length == 10;

  void onQueryChanged(String raw) {
    final q = raw.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(q);
    });
  }

  Future<void> _runSearch(String q) async {
    if (q.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: null,
        searchSuggestionResponse: null,
      );
      return;
    }

    final isMobileQuery = _isMobileNumber(q);
    final int mySeq = ++_requestSeq;

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchSuggestionResponse: null,
    );

    final result = await api.searchSuggestions(searchWords: q, query: q);

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
        final shouldFilterMobileHits = _isDigitsOnly(q) && !isMobileQuery;
        final filteredResponse = shouldFilterMobileHits
            ? _filterOutMobileOnlyItems(response)
            : response;

        state = state.copyWith(
          isLoading: false,
          error: null,
          searchSuggestionResponse: filteredResponse,
        );
      },
    );
  }

  SearchSuggestionResponse _filterOutMobileOnlyItems(
    SearchSuggestionResponse response,
  ) {
    final data = response.data;
    if (data == null) return response;

    final filteredItems = data.items
        .where(
          (e) =>
              !_mobileTypes.contains(e.type) &&
              e.target.kind != 'MOBILENO_USER_DETAIL',
        )
        .toList();

    return SearchSuggestionResponse(
      status: response.status,
      data: SearchSuggestionData(query: data.query, items: filteredItems),
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
