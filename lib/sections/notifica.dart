import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/core/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifica extends StatefulWidget {
  const Notifica({super.key});

  @override
  State<Notifica> createState() => _NotificaState();
}

class _NotificaState extends State<Notifica> with TickerProviderStateMixin {
  List<Map<String, dynamic>> nonViste = [];
  Set<String> viste = {};
  bool loading = false;
  bool _isLoading = false;
  int currentPage = 0;
  int? _cardDismissedIndex;
  late AppProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<AppProvider>();
    _provider.addListener(_caricaTutto);
    _caricaTutto();
  }

  @override
  void dispose() {
    _provider.removeListener(_caricaTutto);
    super.dispose();
  }

  Future<void> _caricaTutto() async {
    if (_isLoading) return;
    _isLoading = true;
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    viste = prefs.getStringList('notifiche_viste')?.toSet() ?? {};

    final url = Uri.https(
      constants.PATH,
      constants.ENDPOINT_V2_NOTI_GENE,
      {'agency_id': constants.ID},
    );

    try {
      final list = await _provider.apiService.getV2List(url);

      final oggi = DateTime.now();
      final filtrate = <Map<String, dynamic>>[];

      for (final n in list.cast<Map<String, dynamic>>()) {
        final id = n['id']?.toString() ?? '';
        final scadenza = n['scadenza']?.toString() ?? '';
        bool isScaduta = false;
        if (scadenza.isNotEmpty) {
          final dataScad = DateTime.tryParse(scadenza);
          isScaduta = dataScad != null && dataScad.isBefore(oggi);
        }
        if (!viste.contains(id) && !isScaduta) {
          filtrate.add(n);
        }
      }

      if (mounted) {
        setState(() {
          nonViste = filtrate;
          loading = false;
        });
      }
    } on ApiException catch (e) {
      debugPrint('[NOTIFICA] Errore: $e');
      if (mounted) setState(() => loading = false);
    } catch (e) {
      debugPrint('[NOTIFICA] Errore: $e');
      if (mounted) setState(() => loading = false);
    }
    _isLoading = false;
  }

  Future<void> _segnaVista(String id) async {
    final prefs = await SharedPreferences.getInstance();
    viste.add(id);
    await prefs.setStringList('notifiche_viste', viste.toList());
    setState(() {
      nonViste.removeWhere((n) => n['id']?.toString() == id);
      if (currentPage >= nonViste.length) currentPage = nonViste.length - 1;
    });
  }

  Widget _notificaCard(Map<String, dynamic> notifica, VoidCallback onClose) {
    // v2 field names
    final titolo = notifica['titolo'] ?? '';
    final testo = notifica['testo'] ?? '';
    final link = notifica['link'] ?? '';
    final immagine = notifica['immagine'];

    final dynamic coloriRaw = notifica['colori'];
    List<String> colori;
    if (coloriRaw != null && coloriRaw.toString().isNotEmpty) {
      colori = coloriRaw.toString().split('|');
    } else {
      colori = ['0xff0e70b7', '0xffffffff'];
    }

    Color btnColor;
    try {
      btnColor = Color(int.parse(colori[0]));
    } catch (_) {
      btnColor = const Color(0xff0e70b7);
    }

    if (testo.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (immagine != null && immagine.toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      immagine.toString(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 180,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        titolo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        testo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      if (link.toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: btnColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: () =>
                                constants.openUrl(Uri.parse(link.toString())),
                            child: const Text('Scopri di più'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (nonViste.isEmpty) return const SizedBox.shrink();

    final pageController = PageController(
      viewportFraction: 0.92,
      initialPage: currentPage,
    );

    const maxCardHeight = 360.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxCardHeight + 24,
          child: PageView.builder(
            controller: pageController,
            itemCount: nonViste.length,
            onPageChanged: (idx) => setState(() => currentPage = idx),
            itemBuilder: (context, idx) {
              final notifica = nonViste[idx];
              final isBeingDismissed = _cardDismissedIndex == idx;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                child: GestureDetector(
                  onVerticalDragEnd: (details) async {
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! < -200) {
                      setState(() => _cardDismissedIndex = idx);
                      await Future.delayed(const Duration(milliseconds: 220));
                      _segnaVista(notifica['id']?.toString() ?? '');
                      setState(() => _cardDismissedIndex = null);
                    }
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: isBeingDismissed ? 0.0 : 1.0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      offset: isBeingDismissed
                          ? const Offset(0, -0.13)
                          : Offset.zero,
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: maxCardHeight),
                        child: Material(
                          color: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.zero,
                              child: _notificaCard(
                                notifica,
                                () async {
                                  setState(() => _cardDismissedIndex = idx);
                                  await Future.delayed(
                                      const Duration(milliseconds: 220));
                                  _segnaVista(
                                      notifica['id']?.toString() ?? '');
                                  setState(() => _cardDismissedIndex = null);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(nonViste.length, (idx) {
            final isActive = idx == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: isActive ? 18 : 10,
              height: 10,
              decoration: BoxDecoration(
                color:
                    isActive ? const Color(0xff0e70b7) : Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
