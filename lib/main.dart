import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:opendata/api/api.dart';
import 'package:opendata/page/single_viewer.dart';

import 'api/fr_dpae.dart';

part 'main.gr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenData Viewer',
      darkTheme: ThemeData.dark(),
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(),
    );
  }
}

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: MenuPage, initial: true, path: "/"),
    AutoRoute(page: SingleViewerPage, path: "/single_viewer"),
  ]
)
class AppRouter extends _$AppRouter{}

class MenuPage extends StatelessWidget {
  MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select data you want to visualize'),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              title: Text("URSSAF : DPEA"),
              subtitle: Text("Déclarations préalables à l'embauche"),
              onTap: () => context.router.push(SingleViewerRoute(api: FrDpeaApi())),
            ),
          ],
        )
      ),
    );
  }
}
