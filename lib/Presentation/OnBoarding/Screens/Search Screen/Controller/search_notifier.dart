import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Controller/login_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Search%20Screen/Model/search_suggestion_response.dart';

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
      searchSuggestionResponse:
          searchSuggestionResponse ?? this.searchSuggestionResponse,

      recentItems: recentItems ?? this.recentItems,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  late final ApiDataSource api;
  @override
  SearchState build() {
    api = ref.read(apiDataSourceProvider);
    return SearchState.initial();
  }

  Future<void> searchSuggestion({
    required String searchWords,
    bool force = false,
  }) async {
    state = state.copyWith(isLoading: true, searchSuggestionResponse: null);

    final result = await api.searchSuggestions(searchWords: searchWords);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          searchSuggestionResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          searchSuggestionResponse: response,
        );
      },
    );
  }

  void addRecentItem(SearchItem item) {
    final current = List<SearchItem>.from(state.recentItems);

    current.removeWhere(
          (e) => e.id == item.id && e.type == item.type,
    );

    current.insert(0, item);

    if (current.length > 10) current.removeLast();

    state = state.copyWith(recentItems: current);
  }



  void removeRecentItem(SearchItem item) {
    final current = List<SearchItem>.from(state.recentItems);
    current.removeWhere(
          (e) => e.id == item.id && e.type == item.type,
    );
    state = state.copyWith(recentItems: current);
  }
}


final searchNotifierProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
