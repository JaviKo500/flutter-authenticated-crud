
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';


class ProductScreen extends ConsumerWidget {
  final String productId;
  const ProductScreen ({Key? key, required this.productId}) : super(key: key);

  void showSnackBar( BuildContext context, String message ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text( message ))
    );
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final productState = ref.watch( productProvider(productId) );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit product',
            style: TextStyle()
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final photoPath = await CameraGalleryServiceImpl().takePhoto();
                if ( photoPath == null ) return;
                ref.read( productFormProvider( productState.product! ).notifier )
                  .updateProductImage(photoPath);
              }, 
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            IconButton(
              onPressed: () async {
                final photoPath = await CameraGalleryServiceImpl().selectPhoto();
                if ( photoPath == null ) return;
                ref.read( productFormProvider( productState.product! ).notifier )
                  .updateProductImage(photoPath);
              }, 
              icon: const Icon(Icons.photo_library_rounded),
            )
          ],
        ),
        body:  productState.isLoading 
            ? const FullScreenLoader()
            : _ProductView(product: productState.product! ),
        floatingActionButton: FloatingActionButton(
          onPressed: productState.isLoading
            ? null
            : () {
              if ( productState.product == null ) return;
              ref.read( productFormProvider( productState.product! ).notifier )
              .onFormSubmit().then( (value) {
                if( !value ) return;
                final message = productId == 'new' ? 'Product created' : 'Product updated';
                
                FocusScope.of(context).unfocus();
                showSnackBar(context, message);
              }, );
      
            }
          ,
          child: const Icon(Icons.save_as_outlined),
        ),
      ),
    );
  }
}


class _ProductView extends ConsumerWidget {

  final Product product;

  const _ProductView({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productForm = ref.watch( productFormProvider( product ) );
    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: [
    
          SizedBox(
            height: 250,
            width: 600,
            child: _ImageGallery(images: productForm.images ),
          ),
    
          const SizedBox( height: 10 ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: Text( productForm.title.value, style: textStyles.titleSmall, textAlign: TextAlign.center, )),
          ),
          const SizedBox( height: 10 ),
          _ProductInformation( product: product ),
          
        ],
    );
  }
}


class _ProductInformation extends ConsumerWidget {
  final Product product;
  const _ProductInformation({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {

    final productForm = ref.watch( productFormProvider( product ) );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generales'),
          const SizedBox(height: 15 ),
          CustomProductField( 
            isTopField: true,
            label: 'Nombre',
            initialValue: productForm.title.value,
            onChanged: ref.read( productFormProvider( product ).notifier ).onTitleChange,
            errorMessage: productForm.title.errorMessage,
          ),
          CustomProductField( 
            isTopField: true,
            label: 'Slug',
            initialValue: productForm.slug.value,
            onChanged: ref.read( productFormProvider( product ).notifier ).onSlugChange,
            errorMessage: productForm.slug.errorMessage,
          ),
          CustomProductField( 
            isBottomField: true,
            label: 'Precio',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.price.value.toString(),
            onChanged:( value ) =>  ref.read( productFormProvider( product ).notifier ).onPriceChange( double.tryParse(value) ?? -1 ),
            errorMessage: productForm.price.errorMessage,
          ),

          const SizedBox(height: 15 ),
          const Text('Extras'),

          _SizeSelector(
            selectedSizes: productForm.sizes,
            onSizesChanged: ref.read( productFormProvider( product ).notifier ).onSizeChange,
          ),
          const SizedBox(height: 5 ),
          _GenderSelector( 
            selectedGender: productForm.gender, 
            onGenderChanged: ref.read( productFormProvider( product ).notifier ).onGenderChange,
          ),
          

          const SizedBox(height: 15 ),
          CustomProductField( 
            isTopField: true,
            label: 'Existencias',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.inStock.value.toString(),
            onChanged: (value) => ref.read( productFormProvider( product ).notifier ).onStockChange( int.tryParse(value) ?? -1 ),
            errorMessage: productForm.inStock.errorMessage,
          ),

          CustomProductField( 
            maxLines: 6,
            label: 'Descripción',
            keyboardType: TextInputType.multiline,
            initialValue: product.description,
            onChanged: ref.read( productFormProvider( product ).notifier ).onDescriptionChange,
          ),

          CustomProductField( 
            isBottomField: true,
            maxLines: 2,
            label: 'Tags (Separados por coma)',
            keyboardType: TextInputType.multiline,
            initialValue: productForm.tags,
            onChanged: ref.read( productFormProvider( product ).notifier ).onTagsChange,
          ),


          const SizedBox(height: 100 ),
        ],
      ),
    );
  }
}


class _SizeSelector extends StatelessWidget {
  final List<String> selectedSizes;
  final List<String> sizes = const['XS','S','M','L','XL','XXL','XXXL'];

  final Function( List<String> selectedSizes ) onSizesChanged;
  const _SizeSelector({required this.selectedSizes, required this.onSizesChanged});


  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: sizes.map((size) {
        return ButtonSegment(
          value: size, 
          label: Text(size, style: const TextStyle(fontSize: 10))
        );
      }).toList(), 
      selected: Set.from( selectedSizes ),
      onSelectionChanged: (newSelection) {
        FocusScope.of(context).unfocus();
        onSizesChanged( List.from( newSelection ) );
      },
      multiSelectionEnabled: true,
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final List<String> genders = const['men','women','kid'];
  final Function( String gender ) onGenderChanged;
  final List<IconData> genderIcons = const[
    Icons.man,
    Icons.woman,
    Icons.boy,
  ];

  const _GenderSelector({required this.selectedGender, required this.onGenderChanged});


  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        emptySelectionAllowed: false,
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact ),
        segments: genders.map((size) {
          return ButtonSegment(
            icon: Icon( genderIcons[ genders.indexOf(size) ] ),
            value: size, 
            label: Text(size, style: const TextStyle(fontSize: 12))
          );
        }).toList(), 
        selected: { selectedGender },
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus();
          onGenderChanged( newSelection.first );
        },
      ),
    );
  }
}


class _ImageGallery extends StatelessWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if ( images.isEmpty ) {
      return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover ));
    }

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: PageController(
        viewportFraction: 0.7
      ),
      children: images.map((image){
        late ImageProvider imageProvider;
        if ( image.startsWith('http') ) {
          imageProvider = NetworkImage(image);
        } else {
          final file = File( image );
          imageProvider = FileImage( file );
        }
        return Padding(
          padding: const EdgeInsets.symmetric( horizontal: 10 ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            // child: Image.network(image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover, height: 250,)),
            child: FadeInImage(
              image: imageProvider,
              fit: BoxFit.cover,
              placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
              imageErrorBuilder: (context, error, stackTrace) => 
                Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover, height: 250,)
            ),
          ),
        );
      }).toList(),
    );
  }
}