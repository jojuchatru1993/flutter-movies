import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:movies/src/models/movie_model.dart';
import 'package:movies/src/models/actor_model.dart';

class MoviesProvider {
  String _apikey = '887bb1b3e75ef6082bdc10a92d81df4b';
  String _url = 'api.themoviedb.org';
  String _language = 'en';

  int _popularPage = 0;
  bool _loading = false;

  List<Movie> _popular = [];

  final _popularStreamController = StreamController<List<Movie>>.broadcast();

  Function(List<Movie>) get popularSink => _popularStreamController.sink.add;

  Stream<List<Movie>> get popularStream => _popularStreamController.stream;

  void disposeStreams() {
    _popularStreamController?.close();
  }

  Future<List<Movie>> _requestProcess(Uri url) async {
    final request = await http.get(url);
    final decodeData = json.decode(request.body);

    final movies = new Movies.fromJsonList(decodeData['results']);

    return movies.items;
  }

  Future<List<Movie>> getNowPlaying() async {
    final url = Uri.https(_url, '3/movie/now_playing',
        {'api_key': _apikey, 'language': _language});

    return await _requestProcess(url);
  }

  Future<List<Movie>> getPopular() async {
    if (_loading) return [];

    _loading = true;

    _popularPage++;

    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apikey,
      'language': _language,
      'page': _popularPage.toString()
    });

    final request = await _requestProcess(url);

    _popular.addAll(request);

    popularSink(_popular);

    _loading = false;

    return request;
  }

  Future<List<Actor>> getCast(String movieId) async {
    final url = Uri.https(_url, '3/movie/$movieId/credits',
        {'api_key': _apikey, 'language': _language});

    final request = await http.get(url);
    final decodeData = json.decode(request.body);

    final castDecode = new Cast.fromJsonList(decodeData['cast']);

    return castDecode.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_url, '3/search/movie',
        {'api_key': _apikey, 'language': _language, 'query': query});

    return await _requestProcess(url);
  }
}
