import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_model.dart';
import 'product_service.dart';
import 'product_state.dart';
import 'package:flutter/foundation.dart';
class ProductCubit extends Cubit<ProductState> {
  final ProductService _service;
  StreamSubscription<List<Product>>? _subscription;

  ProductCubit(this._service) : super(ProductInitial());

  void loadProducts() {
    _subscription?.cancel();
    emit(ProductLoading());

    try {
      _subscription = _service.watchProducts().listen(
        (products) {
          emit(ProductLoaded(products));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('PRODUCTS STREAM ERROR: $error');
          debugPrintStack(stackTrace: stackTrace);

          emit(ProductFailure(_friendlyError(error)));
        },      );
    } catch (error) {
      emit(ProductFailure(_friendlyError(error)));
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    required int quantity,
  }) async {
    try {
      await _service.addProduct(
        name: name,
        description: description,
        category: category,
        price: price,
        quantity: quantity,
      );
    } catch (error) {
      throw Exception(_friendlyError(error));
    }
  }

  Future<void> updateProduct({
    required Product product,
    required String name,
    required String description,
    required String category,
    required double price,
    required int quantity,
  }) async {
    try {
      await _service.updateProduct(
        product: product,
        name: name,
        description: description,
        category: category,
        price: price,
        quantity: quantity,
      );
    } catch (error) {
      throw Exception(_friendlyError(error));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _service.deleteProduct(id);
    } catch (error) {
      throw Exception(_friendlyError(error));
    }
  }

  String _friendlyError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'unavailable':
          return 'The service is unavailable. Check your internet connection.';
        case 'not-found':
          return 'The requested product could not be found.';
      }
    }

    if (error is StateError) {
      return error.message;
    }

    return 'Unable to complete the operation. Please try again.';
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
