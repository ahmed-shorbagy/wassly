part of 'food_category_cubit.dart';

abstract class FoodCategoryState extends Equatable {
  const FoodCategoryState();

  @override
  List<Object?> get props => [];
}

class FoodCategoryInitial extends FoodCategoryState {}

class FoodCategoryLoading extends FoodCategoryState {}

class FoodCategoryLoaded extends FoodCategoryState {
  final List<FoodCategoryEntity> categories;

  const FoodCategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class FoodCategoryCreated extends FoodCategoryState {}

class FoodCategoryUpdated extends FoodCategoryState {}

class FoodCategoryDeleted extends FoodCategoryState {}

class FoodCategoryError extends FoodCategoryState {
  final String message;

  const FoodCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

