import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/database_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final DatabaseRepository repository;

  CategoryBloc(this.repository) : super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await repository.getCategories(type: event.type);
      emit(state.copyWith(
        status: CategoryStatus.loaded,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.insertCategory(event.category);
      add(const LoadCategories());
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.updateCategory(event.category);
      add(const LoadCategories());
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.deleteCategory(event.id);
      add(const LoadCategories());
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
