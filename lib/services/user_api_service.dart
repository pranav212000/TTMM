import 'package:chopper/chopper.dart';

part 'user_api_service.chopper.dart';

@ChopperApi(baseUrl: '/user')
abstract class UserApiService extends ChopperService {
  // @Get(path: '/{uid}')
  // Future<Response> getUser(@Path('uid') String uid);

  @Get(path: 'checkUser/{phoneNumber}')
  Future<Response> checkUserExists(@Path('phoneNumber') String phoneNumber);

  @Post(path: '/addUser')
  Future<Response> addUser(@Body() Map<String, dynamic> body);

  @Get(path: '/')
  Future<Response> getUser(@Query('phoneNumber') String phoneNumber);

  @Get(path: '/orders')
  Future<Response> getUserOrders(@Query('phoneNumber') String phoneNumber);

  @Get(path: 'syncContacts')
  Future<Response> syncContacts(@Body() Map<String, dynamic> body);

  @Get(path: '/multiple')
  Future<Response> getUsers(@Body() Map<String, dynamic> body);

  static UserApiService create() {
    final client = ChopperClient(
        baseUrl: 'https://ttmm-pp.herokuapp.com/api',
        services: [_$UserApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]);
    return _$UserApiService(client);
  }

  // static UserApiService create() {
  //   final client = ChopperClient(
  //       baseUrl: 'https://jsonplaceholder.typicode.com/',
  //       services: [_$PostApiService()],
  //       converter: JsonConverter());

  //   return _$PostApiService(client);
  // }
}
