import 'package:chopper/chopper.dart';
import 'package:ttmm/shared/constants.dart';

part 'transaction_api_service.chopper.dart';

@ChopperApi(baseUrl: '/transaction')
abstract class TransactionApiService extends ChopperService {

  @Post(path: '/payBill')
  Future<Response> postPayBill (@Query('eventId') String eventId, @Body() Map<String, dynamic> body);

  @Post(path: '/payPerson')
  Future<Response> postPayPerson(@Query('eventId') String eventId, @Body() Map<String, dynamic> body);
  
  @Get(path: 'allToGets')
  Future<Response> allToGets(@Query('eventId') String eventId);

  

  static TransactionApiService create() {
    final client = ChopperClient(
        baseUrl: DB_URL,
        services: [_$TransactionApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]);
    return _$TransactionApiService(client);
  }

  // static UserApiService create() {
  //   final client = ChopperClient(
  //       baseUrl: 'https://jsonplaceholder.typicode.com/',
  //       services: [_$PostApiService()],
  //       converter: JsonConverter());

  //   return _$PostApiService(client);
  // }
}
