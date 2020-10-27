import 'package:chopper/chopper.dart';

part 'firebase_api_service.chopper.dart';

@ChopperApi(baseUrl: '/firebase')
abstract class FirebaseApiService extends ChopperService {
  // @Get(path: '/{uid}')
  // Future<Response> getUser(@Path('uid') String uid);

  @Post(path: '/storeToken')
  Future<Response> storeToken(@Body() Map<String, dynamic> body);

  @Get(path: '/sendNotification')
  Future<Response> sendNotification(@Query('phoneNumber') String phoneNumber);

  static FirebaseApiService create() {
    final client = ChopperClient(
        baseUrl: 'https://ttmm-pp.herokuapp.com/api',
        services: [_$FirebaseApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]);
    return _$FirebaseApiService(client);
  }

  // static UserApiService create() {
  //   final client = ChopperClient(
  //       baseUrl: 'https://jsonplaceholder.typicode.com/',
  //       services: [_$PostApiService()],
  //       converter: JsonConverter());

  //   return _$PostApiService(client);
  // }
}
