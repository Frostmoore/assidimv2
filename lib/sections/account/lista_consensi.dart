import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/user_data.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/core/services/api_service.dart';

class ListaConsensi extends StatefulWidget {
  final UserData userData;
  const ListaConsensi({super.key, required this.userData});

  @override
  State<ListaConsensi> createState() => _ListaConsensiState();
}

class _ListaConsensiState extends State<ListaConsensi> {
  late bool _p2, _p3, _p4;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    bool parse(String? r) => r?.split('|').first == '1';
    _p2 = parse(widget.userData.privacy2);
    _p3 = parse(widget.userData.privacy3);
    _p4 = parse(widget.userData.privacy4);
  }

  Future<void> _save(int id, bool value) async {
    final provider = context.read<AppProvider>();
    final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_PRIVACY);
    setState(() => _busy = true);
    try {
      await provider.apiService.patchJsonV2(url, body: {
        'privacy_id': id,
        'privacy_value': value,
      });
    } on ApiException catch (e) {
      debugPrint('[PRIV] errore $e – rollback');
      setState(() {
        if (id == 2) _p2 = !_p2;
        if (id == 3) _p3 = !_p3;
        if (id == 4) _p4 = !_p4;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore salvataggio')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_busy)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(),
          ),
        if (_busy) const SizedBox(height: 8),
        _toggle(constants.PRIVACY_2, _p2, 2),
        Divider(height: 16, thickness: 1, color: Colors.grey.shade100),
        _toggle(constants.PRIVACY_3, _p3, 3),
        Divider(height: 16, thickness: 1, color: Colors.grey.shade100),
        _toggle(constants.PRIVACY_4, _p4, 4),
      ],
    );
  }

  Widget _toggle(String label, bool value, int id) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeColor: const Color(0xFF1A2A4A),
            onChanged: _busy
                ? null
                : (v) {
                    setState(() {
                      if (id == 2) _p2 = v;
                      if (id == 3) _p3 = v;
                      if (id == 4) _p4 = v;
                    });
                    _save(id, v);
                  },
          ),
        ],
      );
}
