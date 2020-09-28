import 'package:chopper/chopper.dart';

part 'event_api_service.chopper.dart';

@ChopperApi(baseUrl: '/event')
abstract class EventApiService extends ChopperService {
  // @Get(path: '/{uid}')
  // Future<Response> getUser(@Path('uid') String uid);

  @Post(path: '/addEvent')
  Future<Response> addEvent(
      @Query('groupId') String groupId, @Body() Map<String, dynamic> body);

  @Get(path: '/')
  Future<Response> getEvent(@Query('eventId') String eventId);

  @Get(path: '/multiple')
  Future<Response> getEvents(@Body() Map<String, dynamic> body);

  @Post(path: '/{eventId}/addOrder')
  Future<Response> addOrder(
      @Path('eventId') String eventId, @Body() Map<String, dynamic> body);

  @Get(path: '/{eventId}/orders')
  Future<Response> getOrders(
      @Path('eventId') String eventId);

  static EventApiService create() {
    final client = ChopperClient(
        baseUrl: 'https://ttmm-pp.herokuapp.com/api',
        services: [_$EventApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]);
    return _$EventApiService(client);
  }

  // static UserApiService create() {
  //   final client = ChopperClient(
  //       baseUrl: 'https://jsonplaceholder.typicode.com/',
  //       services: [_$PostApiService()],
  //       converter: JsonConverter());

  //   return _$PostApiService(client);
  // }
}