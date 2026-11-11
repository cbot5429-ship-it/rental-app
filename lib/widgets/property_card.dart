import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final VoidCallback? onTap;
  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
    final fav = await FavoriteService.isFavorite(widget.property['id']);
    if (mounted) setState(() => _isFav = fav);
  }

  Future<void> _toggleFav() async {
    setState(() => _isFav = !_isFav); // optimistic UI update
    try {
      await FavoriteService.toggle(widget.property['id']);
    } catch (_) {
      if (mounted) setState(() => _isFav = !_isFav); // revert on fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = (widget.property['images'] as List?)?.cast<String>() ?? [];
    final imageUrl = images.isNotEmpty ? images.first : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                          placeholder: (_, __) => Container(color: Colors.grey.shade200),
                          errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.home)),
                        )
                      : Container(color: Colors.grey.shade200, child: const Icon(Icons.home)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border, color: _isFav ? Colors.red : Colors.grey),
                      onPressed: _toggleFav,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.property['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(widget.property['city'] ?? '', style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${widget.property['bedrooms'] ?? 0} bed', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 12),
                      Text('${widget.property['bathrooms'] ?? 0} bath', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const Spacer(),
                      Text('\$${widget.property['price_per_month']}/mo', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
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
}