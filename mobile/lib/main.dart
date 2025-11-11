import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/config/theme/app_theme.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/core/utils/logger.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/users/data/repositories/user.dart';
import 'package:mobile/routes/app_router.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';

import 'features/users/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  AppLogger.init();

  // Initialize secure storage
  await SecureStorageService.init();

  // Initialize DIO client
  DioClient.init();

  runApp(const HealthcareApp());
}

class HealthcareApp extends StatelessWidget {
  const HealthcareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  AuthBloc(navigatorKey: AppRouter.navigatorKey)
                    ..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            UserRepository(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
