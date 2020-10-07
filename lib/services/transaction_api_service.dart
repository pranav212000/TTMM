import 'package:chopper/chopper.dart';

part 'transaction_api_service.chopper.dart';

@ChopperApi(baseUrl: '/transaction')
abstract class TransactionApiService extends ChopperService {

  @Post(path: '/paid')
  Future<Response> postPaid (@Query('eventId') String eventId, @Body() Map<String, dynamic> body);




  // @Get(path: '/{uid}')
  // Future<Response> getUser(@Path('uid') String uid);

  // @Post(path: '/addEvent')
  // Future<Response> addEvent(@Query('groupId') String groupId,
  //     @Query('split') String split, @Body() Map<String, dynamic> body);

  // @Get(path: '/')
  // Future<Response> getEvent(@Query('eventId') String eventId);

  // @Get(path: '/multiple')
  // Future<Response> getEvents(@Body() Map<String, dynamic> body);

  // @Post(path: '/{eventId}/addOrder')
  // Future<Response> addOrder(
  //     @Path('eventId') String eventId, @Body() Map<String, dynamic> body);

  // @Get(path: '/{eventId}/orders')
  // Future<Response> getOrders(@Path('eventId') String eventId);

  // @Delete(path: '/deleteOrder')
  // Future<Response> deleteOrder(@Query('orderId') String orderId);

  static TransactionApiService create() {
    final client = ChopperClient(
        baseUrl: 'https://ttmm-pp.herokuapp.com/api',
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
