import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';

class BusinessMap extends StatefulWidget {
  final List<Business> businesses;
  final Business? highlight;
  final LatLng? userLocation;
  final double height;
  final ValueChanged<Business>? onBusinessTap;
  final bool showUserLocation;
  final String? emptyMessage;
  final bool active;

  const BusinessMap({
    super.key,
    required this.businesses,
    this.highlight,
    this.userLocation,
    this.height = 220,
    this.onBusinessTap,
    this.showUserLocation = true,
    this.emptyMessage,
    this.active = true,
  });

  @override
  State<BusinessMap> createState() => _BusinessMapState();
}

class _BusinessMapState extends State<BusinessMap> {
  GoogleMapController? _controller;

  static const _defaultTarget = LatLng(49.328, -123.09);

  List<Business> get _mapped =>
      widget.businesses.where((b) => b.hasLocation).toList();

  @override
  void didUpdateWidget(BusinessMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) {
      _controller = null;
      return;
    }
    if (_controller != null &&
        (oldWidget.businesses != widget.businesses ||
            oldWidget.userLocation != widget.userLocation ||
            oldWidget.highlight?.id != widget.highlight?.id ||
            !oldWidget.active && widget.active)) {
      _fitCamera(_controller!);
    }
  }

  LatLng _initialTarget() {
    if (widget.highlight?.hasLocation == true) {
      return LatLng(widget.highlight!.lat!, widget.highlight!.lng!);
    }
    if (widget.userLocation != null) return widget.userLocation!;
    if (_mapped.isNotEmpty) {
      return LatLng(_mapped.first.lat!, _mapped.first.lng!);
    }
    return _defaultTarget;
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (widget.showUserLocation && widget.userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: widget.userLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You'),
          zIndexInt: 0,
        ),
      );
    }

    for (final biz in _mapped) {
      final isHighlight = widget.highlight?.id == biz.id || _mapped.length == 1;
      markers.add(
        Marker(
          markerId: MarkerId(biz.id),
          position: LatLng(biz.lat!, biz.lng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isHighlight ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRose,
          ),
          infoWindow: InfoWindow(
            title: biz.name,
            snippet: biz.addr ?? biz.cat,
          ),
          onTap: () => widget.onBusinessTap?.call(biz),
          zIndexInt: isHighlight ? 2 : 1,
        ),
      );
    }

    return markers;
  }

  Future<void> _fitCamera(GoogleMapController controller) async {
    final points = <LatLng>[
      ..._mapped.map((b) => LatLng(b.lat!, b.lng!)),
      if (widget.showUserLocation && widget.userLocation != null)
        widget.userLocation!,
    ];

    if (points.isEmpty) {
      await controller.moveCamera(
        CameraUpdate.newLatLngZoom(_initialTarget(), 13),
      );
      return;
    }

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    const padding = 0.002;
    if ((maxLat - minLat).abs() < padding) {
      minLat -= padding;
      maxLat += padding;
    }
    if ((maxLng - minLng).abs() < padding) {
      minLng -= padding;
      maxLng += padding;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        56,
      ),
    );
  }

  String? get _overlayMessage {
    if (_mapped.isNotEmpty) return null;
    return widget.emptyMessage ??
        (widget.userLocation == null
            ? 'Enable location to see nearby spots on the map.'
            : 'Pinned businesses will appear here.');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return _MapPlaceholder(height: widget.height);
    }

    final overlayMessage = _overlayMessage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            GoogleMap(
              key: ValueKey(
                '${widget.userLocation?.latitude}_${widget.userLocation?.longitude}_${_mapped.length}',
              ),
              initialCameraPosition: CameraPosition(
                target: _initialTarget(),
                zoom: widget.highlight?.hasLocation == true ? 16 : 13,
              ),
              markers: _buildMarkers(),
              myLocationEnabled:
                  widget.showUserLocation && widget.userLocation != null,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              onMapCreated: (controller) async {
                _controller = controller;
                await _fitCamera(controller);
              },
            ),
            if (overlayMessage != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    overlayMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: QubyColors.textDimDark,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final double height;

  const _MapPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2518),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E4030)),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
