part of 'service.dart';

@ChopperApi(baseUrl: '/auth')
abstract class AuthService extends ChopperService {
  @Post(path: '/sign-in')
  Future<Response> postSignIn(@Body() JsonBody body);

  @Post(path: '/sign-up')
  Future<Response> postSignUp();

  @Get(path: '/renew')
  Future<Response> getRenew();

  @Post(path: '/verify-email')
  Future<Response> postVerifyEmail();

  @Post(path: '/reset-password-email')
  Future<Response> postResetPasswordEmail();

  @Post(path: '/reset-password')
  Future<Response> postResetPassword();

  static AuthService create([ChopperClient? client]) => _$AuthService(client);
}
