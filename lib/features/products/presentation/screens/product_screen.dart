import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';


class ProductScreen extends ConsumerStatefulWidget {
  final String prodId;
  const ProductScreen ({required this.prodId, super.key});

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends ConsumerState<ProductScreen> {

  @override
  void initState() {
    super.initState();
    ref.read( productProvider( widget.prodId ) );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Product',
          style: TextStyle()
        ),
      ),
      body: Center(
        child: Text(
          widget.prodId,
          style: const TextStyle()
        ),
      ),
    );
  }
}