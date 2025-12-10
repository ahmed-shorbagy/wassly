import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/article_repository.dart';
import 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticleRepository repository;

  ArticleCubit({required this.repository}) : super(ArticleInitial());

  Future<void> loadPublishedArticles() async {
    emit(ArticleLoading());
    final result = await repository.getPublishedArticles();
    result.fold(
      (failure) {
        AppLogger.logError('Failed to load articles', error: failure);
        emit(ArticleError(failure.message));
      },
      (articles) {
        AppLogger.logSuccess('Loaded ${articles.length} articles');
        emit(ArticleLoaded(articles: articles));
      },
    );
  }

  Future<void> loadAllArticles() async {
    emit(ArticleLoading());
    final result = await repository.getAllArticles();
    result.fold(
      (failure) {
        AppLogger.logError('Failed to load articles', error: failure);
        emit(ArticleError(failure.message));
      },
      (articles) {
        AppLogger.logSuccess('Loaded ${articles.length} articles');
        emit(ArticleLoaded(articles: articles));
      },
    );
  }

  Future<void> createArticle(ArticleEntity article) async {
    final result = await repository.createArticle(article);
    result.fold(
      (failure) {
        AppLogger.logError('Failed to create article', error: failure);
        emit(ArticleError(failure.message));
      },
      (_) {
        AppLogger.logSuccess('Article created successfully');
        loadAllArticles();
      },
    );
  }

  Future<void> updateArticle(ArticleEntity article) async {
    final result = await repository.updateArticle(article);
    result.fold(
      (failure) {
        AppLogger.logError('Failed to update article', error: failure);
        emit(ArticleError(failure.message));
      },
      (_) {
        AppLogger.logSuccess('Article updated successfully');
        loadAllArticles();
      },
    );
  }

  Future<void> deleteArticle(String id) async {
    final result = await repository.deleteArticle(id);
    result.fold(
      (failure) {
        AppLogger.logError('Failed to delete article', error: failure);
        emit(ArticleError(failure.message));
      },
      (_) {
        AppLogger.logSuccess('Article deleted successfully');
        loadAllArticles();
      },
    );
  }
}

