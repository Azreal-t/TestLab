import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'data/services/http_service.dart';
import 'data/services/storage_service.dart';
import 'presentation/controllers/test_lab_controller.dart';
import 'presentation/widgets/request_pane.dart';
import 'presentation/widgets/response_pane.dart';
import 'presentation/widgets/sidebar_content.dart';

void main() {
  runApp(const DioTestLabApp());
}

class DioTestLabApp extends StatelessWidget {
  const DioTestLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Test Lab',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TestLabController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Inject services (Dependency Inversion Principle)
    final HttpService httpService = DioHttpService();
    final StorageService storageService = SharedPrefsStorageService();
    
    _controller = TestLabController(
      httpService: httpService,
      storageService: storageService,
    );

    _initController();
  }

  Future<void> _initController() async {
    await _controller.init();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return Scaffold(
              appBar: AppBar(
                leading: isWide
                    ? IconButton(
                        icon: Icon(_controller.isSidebarVisible
                            ? Icons.view_sidebar_rounded
                            : Icons.view_sidebar_outlined),
                        tooltip: 'Alternar Barra Lateral',
                        onPressed: _controller.toggleSidebar,
                      )
                    : null,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurpleAccent),
                      ),
                      child: const Text(
                        'DIO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Test Lab',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Dio Test Lab',
                        applicationVersion: '1.0.0',
                        children: [
                          const Text(
                            'Ferramenta rápida para testar requisições HTTP usando Dio.\n\n'
                            'Nota para Web: Lembre-se que requisições na Web estão sujeitas à política de CORS do navegador.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              drawer: isWide
                  ? null
                  : Drawer(
                      backgroundColor: const Color(0xFF12121A),
                      child: SidebarContent(controller: _controller),
                    ),
              body: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_controller.isSidebarVisible) ...[
                          SizedBox(
                            width: 280,
                            child: SidebarContent(controller: _controller),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ],
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: RequestPane(controller: _controller),
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          flex: 6,
                          child: ResponsePane(controller: _controller),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          RequestPane(controller: _controller),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 500,
                            child: ResponsePane(controller: _controller),
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
