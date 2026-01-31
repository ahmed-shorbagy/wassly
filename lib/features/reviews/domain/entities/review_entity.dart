class ReviewEntity {
  final String id;
  final String orderId;
  final String reviewerName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.orderId,
    required this.reviewerName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  // Factory for mock data (temporary until API is ready)
  factory ReviewEntity.mock(int index) {
    return ReviewEntity(
      id: 'review_$index',
      orderId: 'order_$index',
      reviewerName: 'Customer ${index + 1}',
      rating: (3.0 + (index % 3)), // 3.0, 4.0, 5.0
      comment: index % 2 == 0 ? 'Great service! vary tasty food.' : null,
      createdAt: DateTime.now().subtract(Duration(days: index)),
    );
  }
}
