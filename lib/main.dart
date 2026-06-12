import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/core/services/api_service.dart';
import 'package:Assidim/core/storage/app_storage.dart';
import 'package:Assidim/firebase_options.dart';
import 'package:Assidim/home.dart';
import 'package:Assidim/pages/documento.dart';
import 'package:Assidim/pages/preventivo.dart';
import 'package:Assidim/pages/sinistro.dart';
import 'package:Assidim/sections/account/gestione_consensi.dart';
import 'package:Assidim/sections/accountcontainer.dart';
import 'package:Assidim/sections/chiamata_rapida.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Push handler (background)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await [
    Permission.locationWhenInUse,
    Permission.notification,
  ].request();

  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────────────────
//  MyApp
// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final api = ApiService();
        final storage = AppStorage();
        final provider = AppProvider(api: api, storage: storage);
        provider.init(); // carica config + auto-login in background
        return provider;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: constants.TITLE,
        theme: ThemeData(
          colorScheme: const ColorScheme.highContrastLight(),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const MyHomePage(),
          '/sinistro': (context) => SinistroForm(),
          '/preventivo': (context) => PreventivoForm(),
          '/documento': (context) => DocumentoForm(),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MyHomePage
// ─────────────────────────────────────────────────────────────────────────────

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupOneSignalListener();
  }

  void _setupOneSignalListener() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      context.read<AppProvider>().triggerNotificheRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (provider.isLoadingConfig) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(constants.COLORE_PRINCIPALE),
              ),
            ),
          );
        }

        // ── Errore di rete ───────────────────────────────────────────────────
        if (!provider.hasConfig) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Impossibile contattare il server.\n'
                      'Controlla la connessione e riprova.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── App caricata ─────────────────────────────────────────────────────
        final config = provider.config!;

        // Inizializza OneSignal con l'app ID dalla config
        OneSignal.initialize(config.osAppId);

        final secondaryColor = config.secondaryColor;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context),
          body: switch (_selectedIndex) {
            0 => const HomePage(),
            1 => const AccountContainer(),
            _ => GestioneConsensi(goHome: () => setState(() => _selectedIndex = 0)),
          },
          floatingActionButton: const ChiamataRapida(), // ignore: prefer_const_constructors
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: secondaryColor,
            unselectedItemColor: secondaryColor,
            unselectedLabelStyle: TextStyle(color: secondaryColor),
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Agenzia'),
              BottomNavigationBarItem(icon: Icon(Icons.account_box), label: 'Account'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Impostazioni'),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(constants.TITLE)],
    ),
  );
}
