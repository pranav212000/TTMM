import 'package:chopper/chopper.dart';
import 'package:ttmm/shared/constants.dart';

part 'group_api_service.chopper.dart';

@ChopperApi(baseUrl: '/group')
abstract class GroupApiService extends ChopperService {
  // @Get(path: '/{uid}')
  // Future<Response> getUser(@Path('uid') String uid);

  @Post(path: '/addGroup')
  Future<Response> addGroup(@Body() Map<String, dynamic> body);

  @Get(path: '/')
  Future<Response> getGroup(@Query('groupId') String groupId);

  @Get(path: '/multiple')
  Future<Response> getGroups(@Body() Map<String, dynamic> body);

  @Get(path: '/{orderId}/events')
  Future<Response> getEvents(@Path('orderId') String orderId);

  @Get(path: '/members')
  Future<Response> getMembersByGroupId(@Query('groupId') String groupId);

  @Get(path: '/members')
  Future<Response> getMembersByEventId(@Query('eventId') String eventId);


  static GroupApiService create() {
    final client = ChopperClient(
        baseUrl: DB_URL,
        services: [_$GroupApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]);
    return _$GroupApiService(client);
  }

  // static UserApiService create() {
  //   final client = ChopperClient(
  //       baseUrl: 'https://jsonplaceholder.typicode.com/',
  //       services: [_$PostApiService()],
  //       converter: JsonConverter());

  //   return _$PostApiService(client);
  // }
}
