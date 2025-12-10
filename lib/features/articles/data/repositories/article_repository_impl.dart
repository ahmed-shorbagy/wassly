import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/article_repository.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore firestore;

  ArticleRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, List<ArticleEntity>>> getPublishedArticles() async {
    try {
      AppLogger.logInfo('Fetching published articles');
      final snapshot = await firestore
          .collection(AppConstants.articlesCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final articles = snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .toList();

      AppLogger.logSuccess('Fetched ${articles.length} published articles');
      return Right(articles);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching articles', error: e);
      return Left(ServerFailure('Failed to fetch articles: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching articles', error: e);
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getAllArticles() async {
    try {
      AppLogger.logInfo('Fetching all articles');
      final snapshot = await firestore
          .collection(AppConstants.articlesCollection)
          .orderBy('createdAt', descending: true)
          .get();

      final articles = snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .toList();

      AppLogger.logSuccess('Fetched ${articles.length} articles');
      return Right(articles);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching articles', error: e);
      return Left(ServerFailure('Failed to fetch articles: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching articles', error: e);
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> getArticleById(String id) async {
    try {
      AppLogger.logInfo('Fetching article: $id');
      final doc = await firestore
          .collection(AppConstants.articlesCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Article not found'));
      }

      final article = ArticleModel.fromFirestore(doc);
      AppLogger.logSuccess('Article fetched: $id');
      return Right(article);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching article', error: e);
      return Left(ServerFailure('Failed to fetch article: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching article', error: e);
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> createArticle(
      ArticleEntity article) async {
    try {
      AppLogger.logInfo('Creating article: ${article.title}');
      final articleModel = ArticleModel.fromEntity(article);
      final docRef = await firestore
          .collection(AppConstants.articlesCollection)
          .add(articleModel.toFirestore());

      final createdArticle = articleModel.copyWith(id: docRef.id);
      AppLogger.logSuccess('Article created: ${docRef.id}');
      return Right(createdArticle);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error creating article', error: e);
      return Left(ServerFailure('Failed to create article: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error creating article', error: e);
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> updateArticle(
      ArticleEntity article) async {
    try {
      AppLogger.logInfo('Updating article: ${article.id}');
      final articleModel = ArticleModel.fromEntity(article);
      await firestore
          .collection(AppConstants.articlesCollection)
          .doc(article.id)
          .update(articleModel.toFirestore());

      AppLogger.logSuccess('Article updated: ${article.id}');
      return Right(articleModel);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating article', error: e);
      return Left(ServerFailure('Failed to update article: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating article', error: e);
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArticle(String id) async {
    try {
      AppLogger.logInfo('Deleting article: $id');
      await firestore.collection(AppConstants.articlesCollection).doc(id).delete();
      AppLogger.logSuccess('Article deleted: $id');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error deleting article', error: e);
      return Left(ServerFailure('Failed to delete article: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error deleting article', error: e);
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

