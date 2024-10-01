import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/presentation/providers/provider.dart';
import 'package:teslo_shop/features/products/infrastructure/infrastructure.dart';

final productsRepositoryProvider = Provider<ProductsRepositoryImpl>((ref) {
  final accessToken = ref.watch( authProvider ).user?.token ?? '';
  final productsRepository = ProductsRepositoryImpl(
    datasource: ProductsDatasourceImpl(
      accessToken: accessToken,
    ),
  );
  return productsRepository;
});