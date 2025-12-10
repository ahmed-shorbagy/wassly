import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../articles/presentation/cubits/article_cubit.dart';
import '../../../articles/presentation/cubits/article_state.dart';
import '../../../articles/domain/entities/article_entity.dart';

class AdminArticleListScreen extends StatefulWidget {
  const AdminArticleListScreen({super.key});

  @override
  State<AdminArticleListScreen> createState() => _AdminArticleListScreenState();
}

class _AdminArticleListScreenState extends State<AdminArticleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ArticleEntity> _filteredArticles = [];
  List<ArticleEntity> _allArticles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _searchController.addListener(_filterArticles);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterArticles);
    _searchController.dispose();
    super.dispose();
  }

  void _loadArticles() {
    context.read<ArticleCubit>().loadAllArticles();
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredArticles = List.from(_allArticles);
      } else {
        _filteredArticles = _allArticles.where((article) {
          final titleMatch = article.title.toLowerCase().contains(query);
          final contentMatch = article.content.toLowerCase().contains(query);
          final authorMatch = article.author?.toLowerCase().contains(query) ?? false;
          return titleMatch || contentMatch || authorMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArticles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterArticles(),
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterArticles();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Articles List
          Expanded(
            child: BlocConsumer<ArticleCubit, ArticleState>(
              listener: (context, state) {
                if (state is ArticleLoaded) {
                  setState(() {
                    _allArticles = state.articles;
                    _filteredArticles = List.from(_allArticles);
                  });
                } else if (state is ArticleError) {
                  context.showErrorSnackBar(state.message);
                }
              },
              builder: (context, state) {
                if (state is ArticleLoading) {
                  return const LoadingWidget();
                }

                if (state is ArticleError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadArticles,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ArticleLoaded) {
                  if (_filteredArticles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.article_outlined, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'No articles found',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = _filteredArticles[index];
                      return _ArticleListItem(
                        article: article,
                        onEdit: () {
                          context.push('/admin/articles/edit/${article.id}');
                        },
                        onDelete: () => _confirmDelete(article),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/articles/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(ArticleEntity article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: Text('Are you sure you want to delete "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ArticleCubit>().deleteArticle(article.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ArticleListItem({
    required this.article,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: article.isPublished ? AppColors.primary : AppColors.textSecondary,
          child: Icon(
            article.isPublished ? Icons.published_with_changes : Icons.drafts,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          article.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.author != null && article.author!.isNotEmpty)
              Text('By: ${article.author}'),
            Text(
              article.content.length > 100
                  ? '${article.content.substring(0, 100)}...'
                  : article.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${article.isPublished ? "Published" : "Draft"} • ${_formatDate(article.createdAt)}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

