part of 'service.dart';

@ChopperApi(baseUrl: '/auth')
abstract class AuthService extends ChopperService {
  @Post(path: '/sign-in')
  Future<Response> signIn(@Body() Map<String, dynamic> body);

  @Post(path: '/sign-up')
  Future<Response> signUp();

  @Post(path: '/renew')
  Future<Response> renew();

  @Post(path: '/verify-email')
  Future<Response> verifyEmail();

  @Post(path: '/reset-password-email')
  Future<Response> resetPasswordEmail();

  @Post(path: '/reset-password')
  Future<Response> resetPassword();

  static AuthService create([ChopperClient? client]) => _$AuthService(client);
}
