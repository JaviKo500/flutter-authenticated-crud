import 'package:dio/dio.dart';
import 'package:teslo_shop/config/constants/environment.dart';

import 'package:teslo_shop/features/products/domain/domain.dart';
import '../errors/product_errors.dart';
import '../mappers/product_mapper.dart';

class ProductsDatasourceImpl extends ProductsDatasource {
  late final Dio dio;
  final String accessToken;
  ProductsDatasourceImpl({required this.accessToken})
      : dio = Dio(
          BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) async {
    try {
      final String productId = productLike['id'] ?? '';
      final String method = productId.isEmpty ? 'POST' : 'PATCH';
      final String url = productId.isEmpty ? '/products' : '/products/$productId';

      productLike.remove('id');
      productLike['images'] = await _uploadPhotos( productLike['images'] );
      // throw Exception();
      final response = await dio.request(
        url,
        data: productLike,
        options: Options(
          method: method,
        )
      );
      final product = ProductMapper.jsonToEntity(response.data);
      return product;
    } catch (e) {
      print(e);
      throw Exception();
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response =
          await dio.get('/products/$id');
      final product = ProductMapper.jsonToEntity( response.data );
      return product;
      
    } on DioException catch (e) {
      if ( e.response!.statusCode == 404 ) throw ProductNotFound();
      throw Exception();
    } catch (e) {
        throw Exception();
    }
  }

  @override
  Future<List<Product>> getProductsByPage(
      {int limit = 10, int offset = 1}) async {
      final response =
        await dio.get<List>('/products?limit=$limit&offset=$offset');
    final List<Product> products = [];

    for (final product in response.data ?? []) {
      products.add(ProductMapper.jsonToEntity(product));
    }
    return products;
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) {
    // TODO: implement searchProductByTerm
    throw UnimplementedError();
  }

  Future<List<String>> _uploadPhotos ( List<String> photos ) async {
    final photosToUpload = photos.where((element) => !element.contains('http')).toList();
    final photosToIgnore = photos.where((element) => element.contains('http')).toList();
    final List<Future<String>> uploadJob = photosToUpload.map( _uploadFile).toList();
    final newImages = await Future.wait( uploadJob );
    return [ ...photosToIgnore, ...newImages ];
  }

  Future<String> _uploadFile ( String path ) async {
    try {
      final fileName = path.split('/').last;
      final contentType = path.split('.').last;
      final FormData data = FormData.fromMap({
        'file': MultipartFile.fromFileSync(path, filename: fileName, contentType: DioMediaType( 'image', contentType ))
      });
      final response = await dio.post( '/files/product', data: data);
      return response.data['image'];
    } catch (e) {
      throw Exception();
    }
  }
}
