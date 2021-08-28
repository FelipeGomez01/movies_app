import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/helpers/debouncer.dart';

import 'package:movies_app/models/models.dart';
import 'package:movies_app/config/constants.dart' as constants;
import 'package:movies_app/models/search_response.dart';

class MoviesProvider extends ChangeNotifier
{
  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  int _popularPage = 0;
  Map<int,List<Cast>> moviesCast = {};
  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionStreamController.stream;
  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500)
  );

  MoviesProvider()
  {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endPoint, [int page = 1]) async
  {
    final url = Uri.https(constants.apiUrl,endPoint,{
      'api_key': constants.apiKey,
      'languaje': constants.language,
      'page': '$page'
    });

    final response = await http.get(url);

    return response.body;
  }

  getOnDisplayMovies() async
  {
    final jsonData = await _getJsonData('3/movie/now_playing');

    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async
  {
    _popularPage++;

    final jsonData = await _getJsonData('3/movie/popular',_popularPage);

    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMovies = [...popularResponse.results, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async
  {
    if(moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');

    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async
  {
    final url = Uri.https(constants.apiUrl,'3/search/movie',{
      'api_key': constants.apiKey,
      'languaje': constants.language,
      'query': query
    });

    final response = await http.get(url);

    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm)
  {
    debouncer.value = '';
    debouncer.onValue = (value) async
    {
      final results = await searchMovie(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), ( _ ) {
      debouncer.value = searchTerm;
    });
    
    Future.delayed(const Duration(milliseconds: 301)).then(( _ ) => timer.cancel());
  }
}