import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ProductScreen extends ConsumerStatefulWidget {
  final String prodId;
  const ProductScreen ({required this.prodId, super.key});

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends ConsumerState<ProductScreen> {
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