import 'package:flutter/cupertino.dart';
import 'package:flutter_mvvm/domain/usecase/DeleteOneMovieUseCase.dart';
import 'package:flutter_mvvm/domain/usecase/GetMovieListFromDatabaseUseCase.dart';
import 'package:flutter_mvvm/domain/usecase/GetMovieListUseCase.dart';
import 'package:intl/intl.dart';

import '../../data/model/BoxOffice.dart';
import '../../data/model/BoxOfficeResponse.dart';
import '../../domain/usecase/SaveOneMovieUseCase.dart';

class MovieViewModel extends ChangeNotifier {
  final SaveOneMovieUseCase _saveOneMovieUseCase;
  final DeleteOneMovieUseCase _deleteOneMovieUseCase;
  final GetMovieListFromDatabaseUseCase _getMovieListFromDatabaseUseCase;
  final GetMovieListUseCase _getMovieListUseCase;
  MovieViewModel(this._deleteOneMovieUseCase, this._saveOneMovieUseCase, this._getMovieListFromDatabaseUseCase, this._getMovieListUseCase);

  BoxOfficeResponse? _movies;
  BoxOfficeResponse? get movies => _movies;

  BoxOffice? _selectedMovie;
  BoxOffice? get selectedMovie => _selectedMovie;

  List<BoxOffice>? _myMovie;
  List<BoxOffice>? get myMovie => _myMovie;


  void selectMovie(int index) async {
    _selectedMovie = _movies!.boxOfficeResult.dailyBoxOfficeList[index];
    print(index);
  }

  void selectMyMovie(int index) async {
    _selectedMovie = _myMovie?[index];
    print(index);
  }

  Future<List<BoxOffice>?> getMovieList(String targetDt, String itemPerPage) async {
    try {
      BoxOfficeResponse fetchedPosts =
          await _getMovieListUseCase.invoke(targetDt, itemPerPage);
      _movies = fetchedPosts;
      await fetchDatabase();
      return fetchedPosts.boxOfficeResult.dailyBoxOfficeList;
    } catch (e) {
      print("Error fetching posts: $e");
    }
    return null;
  }

  Future<List<BoxOffice>?> getRecentMovie() async {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days: 1));
    String yesterdayDate = DateFormat('yyyyMMdd').format(yesterday);
    final movies = await getMovieList(yesterdayDate, "10");
    return movies;
  }

  void saveMovie(BoxOffice? movie) async {
    if (movie == null) return;
    _saveOneMovieUseCase.invoke(movie);
    await fetchDatabase();
  }

  Future<List<BoxOffice>> fetchDatabase() async {
    var movies = await _getMovieListFromDatabaseUseCase.invoke();
    _myMovie = movies;
    notifyListeners();
    return movies;
  }

  void deleteMovie(int index) async {
    _deleteOneMovieUseCase.invoke(myMovie![index]);
    await fetchDatabase();
  }
}
