import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../restaurants/domain/entities/restaurant_category_entity.dart';
import '../../../restaurants/domain/repositories/restaurant_category_repository.dart';

// State
abstract class AdminRestaurantCategoryState extends Equatable {
  const AdminRestaurantCategoryState();

  @override
  List<Object?> get props => [];
}

class AdminRestaurantCategoryInitial extends AdminRestaurantCategoryState {}

class AdminRestaurantCategoryLoading extends AdminRestaurantCategoryState {}

class AdminRestaurantCategoriesLoaded extends AdminRestaurantCategoryState {
  final List<RestaurantCategoryEntity> categories;

  const AdminRestaurantCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class AdminRestaurantCategoryOperationSuccess
    extends AdminRestaurantCategoryState {
  final String message;

  const AdminRestaurantCategoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminRestaurantCategoryError extends AdminRestaurantCategoryState {
  final String message;

  const AdminRestaurantCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AdminRestaurantCategoryCubit extends Cubit<AdminRestaurantCategoryState> {
  final RestaurantCategoryRepository _repository;

  AdminRestaurantCategoryCubit({
    required RestaurantCategoryRepository repository,
  }) : _repository = repository,
       super(AdminRestaurantCategoryInitial());

  Future<void> loadCategories() async {
    emit(AdminRestaurantCategoryLoading());
    final result = await _repository.getCategories();
    result.fold(
      (failure) => emit(AdminRestaurantCategoryError(failure.message)),
      (categories) => emit(AdminRestaurantCategoriesLoaded(categories)),
    );
  }

  Future<void> createCategory({
    required String name,
    File? imageFile,
    int displayOrder = 0,
  }) async {
    emit(AdminRestaurantCategoryLoading());
    final result = await _repository.createCategory(
      name: name,
      imageFile: imageFile,
      displayOrder: displayOrder,
    );
    result.fold(
      (failure) => emit(AdminRestaurantCategoryError(failure.message)),
      (_) {
        emit(
          const AdminRestaurantCategoryOperationSuccess(
            'Category created successfully',
          ),
        );
        loadCategories();
      },
    );
  }

  Future<void> updateCategory({
    required String id,
    String? name,
    File? imageFile,
    bool? isActive,
    int? displayOrder,
  }) async {
    emit(AdminRestaurantCategoryLoading());
    final result = await _repository.updateCategory(
      id: id,
      name: name,
      imageFile: imageFile,
      isActive: isActive,
      displayOrder: displayOrder,
    );
    result.fold(
      (failure) => emit(AdminRestaurantCategoryError(failure.message)),
      (_) {
        emit(
          const AdminRestaurantCategoryOperationSuccess(
            'Category updated successfully',
          ),
        );
        loadCategories();
      },
    );
  }

  Future<void> deleteCategory(String id) async {
    emit(AdminRestaurantCategoryLoading());
    final result = await _repository.deleteCategory(id);
    result.fold(
      (failure) => emit(AdminRestaurantCategoryError(failure.message)),
      (_) {
        emit(
          const AdminRestaurantCategoryOperationSuccess(
            'Category deleted successfully',
          ),
        );
        loadCategories();
      },
    );
  }
}
