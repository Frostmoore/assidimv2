import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Indirizzo extends StatefulWidget {
  const Indirizzo({super.key});

  @override
  State<Indirizzo> createState() => _IndirizzoState();
}

class _IndirizzoState extends State<Indirizzo> {
  String? _currentAddress;
  Position? _currentPosition;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Permessi di geolocalizzazione mancanti. Per favore, abilitarli.')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Permessi di geolocalizzazione mancanti.')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'I Permessi di geolocalizzazione sono stati negati. Attivarli dalle impostazioni.')));
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}\n${place.subAdministrativeArea}\nCAP: ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /*Text('LAT: ${_currentPosition?.latitude ?? ""}'),
        Text('LNG: ${_currentPosition?.longitude ?? ""}'),*/
        OutlinedButton.icon(
          icon: const Icon(Icons.my_location_rounded, size: 17),
          onPressed: _getCurrentPosition,
          label: const Text('Rileva la mia posizione'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          ),
        ),
        constants.SPACER_MINIMAL,
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${_currentAddress ?? ""}',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
