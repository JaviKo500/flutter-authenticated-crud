import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_provider.dart';


class ProductScreen extends ConsumerWidget {
  final String productId;
  const ProductScreen ({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch( productProvider( productId ) );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit product',
          style: TextStyle()
        ),
        actions: [
          IconButton(
            onPressed: () {
              
            }, 
            icon: const Icon(Icons.camera_alt_outlined),
          )
        ],
      ),
      body: Center(
        child: Text('Hello World ${productState.id} ${ productState.product?.title ?? ''}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
        },
        child: const Icon(Icons.save_as_outlined),
      ),
    );
  }
}