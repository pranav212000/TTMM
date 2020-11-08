import 'package:chopper/chopper.dart';
import 'package:ttmm/shared/constants.dart';

part 'firebase_api_service.chopper.dart';

@ChopperApi(baseUrl: '/firebase')
abstract class FirebaseApiService extends ChopperService {
  // @Get(path: '/{uid}')
  // Future<Response> getUser(@Path('uid') String uid);

  @Post(path: '/storeToken')
  Future<Response> storeToken(@Body() Map<String, dynamic> body);

  @Post(path: '/sendCashConfirmation')
  Future<Response> sendCashConfirmation(@Body() Map<String, dynamic> body);

  @Post(path: '/notGotCash')
  Future<Response> sendNotGotCash(@Query('paymentId') String paymentId);

  static FirebaseApiService create() {
    final client = ChopperClient(
        baseUrl: DB_URL,
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
