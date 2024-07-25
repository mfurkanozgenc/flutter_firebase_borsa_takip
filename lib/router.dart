import 'package:go_router/go_router.dart';
import 'package:project/pages/case_page.dart';
import 'package:project/pages/create_page.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/portfoy_page.dart';
import 'package:project/pages/target_page.dart';
import 'package:project/pages/update_user_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/loginPage',
      name: 'Login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/portfoyPage',
      name: 'Portfoy',
      builder: (context, state) => const PortfoyPage(),
    ),
    GoRoute(
      path: '/createPage',
      name: 'Create',
      builder: (context, state) => const CreatePage(),
    ),
    GoRoute(
      path: '/updateUser',
      name: 'UpdateUser',
      builder: (context, state) => const UpdateUserPage(),
    ),
    GoRoute(
      path: '/targetPage',
      name: 'Target',
      builder: (context, state) => const TargetPage(),
    ),
    GoRoute(
      path: '/casePage',
      name: 'Case',
      builder: (context, state) => const CasePage(),
    ),
  ],
  errorBuilder: (context, state) => const LoginPage(),
);
