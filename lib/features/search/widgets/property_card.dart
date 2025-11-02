import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/hotel.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.hotel, this.onTap});
  final Hotel hotel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surface,
        ),
        child: Stack(
          children: [
            // Hero image
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(20),
            //   child: AspectRatio(
            //     aspectRatio: 16 / 9,
            //     child: hotel.imageUrl != null
            //         ? Image.network(hotel.imageUrl!, fit: BoxFit.cover)
            //         : Container(color: Colors.black12, child: const Center(child: Icon(Icons.hotel, size: 42))),
            //   ),
            // ),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: (hotel.imageUrl == null || hotel.imageUrl!.isEmpty)
                    ? _fallback()
                    : CachedNetworkImage(
                  imageUrl: hotel.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.black12),
                      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  errorWidget: (_, __, ___) => _fallback(),
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                    ),
                  ),
                ),
              ),
            ),

            // Badges (rating / stars / price)
            Positioned(
              left: 12,
              top: 12,
              child: Row(
                children: [
                  if (hotel.star != null && hotel.star! > 0)
                    _chip(context, icon: Icons.star, label: '${hotel.star}★'),
                  if (hotel.rating != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _chip(context, icon: Icons.reviews, label: '${hotel.rating}'),
                    ),
                ],
              ),
            ),
            if (hotel.priceDisplay != null)
              Positioned(
                right: 12,
                top: 12,
                child: _pricePill(context, hotel.priceDisplay!),
              ),

            // Title + location
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [hotel.city, hotel.state, hotel.country].where((e) => e.isNotEmpty).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, {required IconData icon, required String label}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF121212).withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, size: 42, color: Colors.black45),
      ),
    );
  }

  Widget _pricePill(BuildContext context, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}
