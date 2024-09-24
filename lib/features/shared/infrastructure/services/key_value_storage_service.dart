

abstract class KeyValueStorageService {
  Future<void> setKeyValue( String key, dynamic value ); 
  Future getValue( String key, dynamic value ); 
  Future<bool> removeValue( String key ); 
}