import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TEMPLATE white-label — copia committabile di constants.dart (gitignored).
//  Lo script di generazione sostituisce i placeholder !XXX e salva il file
//  come lib/assets/constants.dart. Tenere i due file allineati.
// ─────────────────────────────────────────────────────────────────────────────

const String TITLE = '!NOME_APP';
const String APPID = '!APP_ID';
const String ID = '!ID_APP';
const String TOKEN = '!TOKEN';

// ─────────────────────────────────────────────────────────────────────────────
//  Endpoint API v2 — server hybridandgogsv2 (Laravel)
//  Path canonici documentati in API_V2.md; le vecchie costanti v1 sono state
//  rimosse (il nuovo server espone solo la v2).
// ─────────────────────────────────────────────────────────────────────────────

/// true in produzione (HTTPS); false per il test locale in HTTP
/// (es. server di sviluppo raggiunto dall'emulatore Android su 10.0.2.2:8001).
const bool USE_HTTPS = true;

const String PATH = 'www.hybridandgogsv2.it';

/// Costruisce gli URI verso il backend rispettando USE_HTTPS.
Uri apiUri(String path, [Map<String, dynamic>? queryParameters]) => USE_HTTPS
    ? Uri.https(PATH, path, queryParameters)
    : Uri.http(PATH, path, queryParameters);

const String ENDPOINT_V2_CONFIG = '/res/api/v2/agency.php';
const String ENDPOINT_V2_LOGIN = '/res/api/v2/auth/login.php';
const String ENDPOINT_V2_REFRESH = '/res/api/v2/auth/refresh.php';
const String ENDPOINT_V2_LOGOUT = '/res/api/v2/auth/logout.php';
const String ENDPOINT_V2_REG = '/res/api/v2/auth/register.php';
const String ENDPOINT_V2_PASS = '/res/api/v2/auth/forgot-password.php';
const String ENDPOINT_V2_ME = '/res/api/v2/user/me.php';
const String ENDPOINT_V2_PASSWORD = '/res/api/v2/user/password.php';
const String ENDPOINT_V2_PRIVACY = '/res/api/v2/user/privacy.php';
const String ENDPOINT_V2_NOTI = '/res/api/v2/notifications/index.php';
const String ENDPOINT_V2_NOTI_SINGLE = '/res/api/v2/notifications/single.php';
const String ENDPOINT_V2_NOTI_READ = '/res/api/v2/notifications/read.php';
const String ENDPOINT_V2_NOTI_GENE = '/res/api/v2/notifications/general.php';
const String ENDPOINT_V2_SINISTRO = '/res/api/v2/claims/sinistro.php';
const String ENDPOINT_V2_PREVENTIVO = '/res/api/v2/claims/preventivo.php';
const String ENDPOINT_V2_DOCUMENTO = '/res/api/v2/claims/documento.php';
const String ENDPOINT_V2_POLIZZE = '/res/api/v2/polizze/index.php';

/// Base URL per le immagini servite dal backend.
final String IMG_PATH = '${USE_HTTPS ? 'https' : 'http'}://$PATH/res/';

// ─────────────────────────────────────────────────────────────────────────────
//  Colori di fallback (usati prima che la config API sia disponibile)
// ─────────────────────────────────────────────────────────────────────────────

const Color COLORE_PRINCIPALE = Color(0xffdf842c);
const Color COLORE_SECONDARIO = Color(0xff2b346b);
const Color COLORE_TERZIARIO = Color(0xff2b346b);

// ─────────────────────────────────────────────────────────────────────────────
//  Placeholder white-label (sostituiti dallo script di generazione)
// ─────────────────────────────────────────────────────────────────────────────

const String TESTOCAI = '!TESTO_CAI';
const String LABEL_BOTTONE_CAI = '!LABEL_CAI';
const String TITOLO_FORM_DENUNCIA = '!TITOLO_DENUNCIA';
final Uri CAI_LINK = Uri.parse('!CAI_LINK');

// ─────────────────────────────────────────────────────────────────────────────
//  Testi statici UI
// ─────────────────────────────────────────────────────────────────────────────

const String SINISTRO_TESTO_BOTTONE = 'Denuncia un Sinistro!';
const String CHIAMATA_RAPIDA_UNO = 'Chiamata Rapida';
const String CHIAMATA_RAPIDA_DUE = 'Whatsapp';
const String CHIAMATA_RAPIDA_TRE = 'e-mail Rapida';
const String ERRORE =
    "Impossibile effettuare l'operazione. Contatta l'amministrazione.";

// ─────────────────────────────────────────────────────────────────────────────
//  Testi privacy (invarianti per legge)
// ─────────────────────────────────────────────────────────────────────────────

const String PRIVACY_2 =
    "Acconsento al trattamento dei miei dati personali di natura comune per "
    "finalità di informazione e promozione commerciale di prodotti e/o servizi, "
    "a mezzo posta o telefono e/o mediante comunicazioni elettroniche quali "
    "e-mail, fax, messaggi del tipo SMS o MMS ovvero con sistemi automatizzati, "
    "come specificato ai punti 2a, 2b e 2c dell'informativa.";

const String PRIVACY_3 =
    "Acconsento al trattamento dei miei dati personali di natura comune per "
    "finalità di comunicazione dei dati a soggetti terzi, operanti nel settore "
    "assicurativo e nei settori complementari a quello assicurativo, ai fini di "
    "informazione e promozione commerciale di prodotti e/o servizi, anche "
    "mediante tecniche di comunicazione a distanza, da parte degli stessi, come "
    "specificato al punto 2d dell'informativa.";

const String PRIVACY_4 =
    "Acconsento al trattamento dei miei dati personali di natura comune per "
    "finalità di profilazione volta ad analizzare i bisogni e le esigenze "
    "assicurative del cliente per l'individuazione, anche attraverso elaborazioni "
    "elettroniche, dei possibili prodotti e/o servizi in linea con le preferenze "
    "e gli interessi della clientela come specificato al punto 2e dell'informativa.";

// ─────────────────────────────────────────────────────────────────────────────
//  Asset statici (SVG / PNG locali)
// ─────────────────────────────────────────────────────────────────────────────

SvgPicture svgFacebook() =>
    SvgPicture.asset('lib/assets/facebook.svg', width: 50);
SvgPicture svgGoogle() => SvgPicture.asset('lib/assets/google.svg', width: 40);
SvgPicture svgInstagram() =>
    SvgPicture.asset('lib/assets/instagram.svg', width: 40);
SvgPicture svgLinkedin() =>
    SvgPicture.asset('lib/assets/linkedin.svg', width: 50);
SvgPicture svgWhatsapp({Color? color}) => SvgPicture.asset(
      'lib/assets/whatsapp.svg',
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );

Widget get IMAGE_WEBSITE => Image.asset('lib/assets/website.png', width: 40);
const AssetImage IMAGE_BUILDING = AssetImage('lib/assets/agenzia.png');

// ─────────────────────────────────────────────────────────────────────────────
//  Stili tipografici (indipendenti dai colori dinamici)
// ─────────────────────────────────────────────────────────────────────────────

const TextStyle EVIDENZA = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
const TextStyle BOLD = TextStyle(fontWeight: FontWeight.bold);
const TextStyle H1 = TextStyle(fontWeight: FontWeight.bold, fontSize: 22);

// ─────────────────────────────────────────────────────────────────────────────
//  Spaziatori
// ─────────────────────────────────────────────────────────────────────────────

const Widget SPACER = SizedBox(height: 25);
const Widget SPACER_MINIMAL = SizedBox(height: 5);
const Widget SPACER_MEDIUM = SizedBox(height: 10);

// ─────────────────────────────────────────────────────────────────────────────
//  Stili bottoni — usano colori di fallback; i widget dinamici usano
//  AppConfig.tertiaryColor / primaryColor direttamente.
// ─────────────────────────────────────────────────────────────────────────────

ButtonStyle buttonStyle(Color background) => ButtonStyle(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      backgroundColor: WidgetStateProperty.all(background),
      foregroundColor: WidgetStateProperty.all(Colors.white),
    );

final ButtonStyle STILE_BOTTONE = buttonStyle(COLORE_TERZIARIO);
final ButtonStyle STILE_BOTTONE_ROSSO = buttonStyle(Colors.red.shade400);
final ButtonStyle STILE_BOTTONE_ALT =
    buttonStyle(const Color.fromARGB(255, 12, 68, 22));

final ButtonStyle STILE_NOTIFICA = ButtonStyle(
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  ),
  backgroundColor: WidgetStateProperty.all(Colors.transparent),
  surfaceTintColor: WidgetStateProperty.all(Colors.white),
  foregroundColor: WidgetStateProperty.all(Colors.black),
);

// ─────────────────────────────────────────────────────────────────────────────
//  Helper URL
// ─────────────────────────────────────────────────────────────────────────────

Future<void> openUrl(Uri uri) async {
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception(ERRORE);
  }
}
