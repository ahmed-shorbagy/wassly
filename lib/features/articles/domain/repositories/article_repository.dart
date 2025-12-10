import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article_entity.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<ArticleEntity>>> getPublishedArticles();
  Future<Either<Failure, List<ArticleEntity>>> getAllArticles();
  Future<Either<Failure, ArticleEntity>> getArticleById(String id);
  Future<Either<Failure, ArticleEntity>> createArticle(ArticleEntity article);
  Future<Either<Failure, ArticleEntity>> updateArticle(ArticleEntity article);
  Future<Either<Failure, void>> deleteArticle(String id);
}

