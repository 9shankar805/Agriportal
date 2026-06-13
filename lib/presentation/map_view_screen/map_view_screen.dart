import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_export.dart';
import '../../core/firestore_service.dart';
import '../../core/app_localizations.dart';
import '../../routes/app_routes.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final List<LandModel> _lands = [];
  bool _isLoading = true;
  final LatLng _initialPosition = const LatLng(27.7172, 85.3240); // Kathmandu

  @override
  void initState() {
    super.initState();
    _loadLands();
  }

  Future<void> _loadLands() async {
    try {
      final snapshot = await FirestoreService.instance.activeLandsStream().first;
      final lands = snapshot.docs.map(LandModel.fromFirestore).toList();
      if (mounted) {
        final t = AppLocalizations.of(context);
        setState(() {
          _lands.addAll(lands);
          _isLoading = false;
          _createMarkers(lands, t);
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _createMarkers(List<LandModel> lands, AppLocalizations t) {
    final markers = <Marker>{};
    for (var i = 0; i < lands.length; i++) {
      final land = lands[i];
      if (land.latitude != null && land.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(land.id),
            position: LatLng(land.latitude!, land.longitude!),
            infoWindow: InfoWindow(
              title: land.title,
              snippet: 'NPR ${land.leasePriceMonthly}${t.perMonthSuffix} - ${land.areaRopani} Ropani',
              onTap: () => context.push(AppRoutes.landDetail, extra: land.id),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }
    }
    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.mapView,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
            ),
    );
  }
}
