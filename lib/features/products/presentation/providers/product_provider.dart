import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';

import 'products_repository_provider.dart';

final productProvider = StateNotifierProvider.autoDispose.family<ProductNotifier, ProductState, String >
  ((ref, productId) {

    final productRepository = ref.watch( productsRepositoryProvider );
    return ProductNotifier(
      productId: productId, 
      productsRepository: productRepository,
    );
  });

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductsRepository productsRepository;
  ProductNotifier({ 
    required this.productsRepository,
    required String productId,
  }): super( ProductState( id: productId ) );

  Future<void> loadProduct () async {
    
  }
}

class ProductState {
  final String id;
  final Product? product;
  final bool isLoading;
  final bool isSaving;

  ProductState({
    required this.id, 
    this.product, 
    this.isLoading = true, 
    this.isSaving = false,
  });

  ProductState copyWith({
    String? id,
    Product? product,
    bool? isLoading,
    bool? isSaving,
  }) => ProductState(
    id: id ?? this.id,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    product: product ?? this.product,
  );
  
}