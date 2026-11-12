import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../widgets/reviews_section.dart';
import '../main.dart' show supabase;
import '../services/message_service.dart';
import '../services/rental_request_service.dart';
import '../services/maintenance_service.dart';
import 'chat_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showMaintenanceDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Maintenance Issue'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Describe the issue...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              await MaintenanceService.submitRequest(
                propertyId: widget.property['id'],
                ownerId: widget.property['owner_id'],
                issue: ctrl.text.trim(),
              );
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance request sent!')));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = (widget.property['images'] as List?)?.cast<String>() ?? [];
    final listingType = widget.property['listing_type'] ?? 'rent';
    final priceLabel = listingType == 'buy' ? 'Price' : 'Rent / month';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: isDark ? Colors.black : Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isEmpty
                  ? Container(color: Colors.grey.shade800, child: const Icon(Icons.home, size: 64, color: Colors.white54))
                  : ClipRRect(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (index) => setState(() => _currentPage = index),
                            itemBuilder: (_, i) => Container(
                              color: Colors.black,
                              child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.contain, memCacheWidth: 800),
                            ),
                          ),
                          if (images.length > 1 && _currentPage > 0)
                            Positioned(
                              left: 8, top: 0, bottom: 0,
                              child: Center(child: CircleAvatar(backgroundColor: Colors.black45, child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18), onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)))),
                            ),
                          if (images.length > 1 && _currentPage < images.length - 1)
                            Positioned(
                              right: 8, top: 0, bottom: 0,
                              child: Center(child: CircleAvatar(backgroundColor: Colors.black45, child: IconButton(icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18), onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)))),
                            ),
                          if (images.length > 1)
                            Positioned(
                              bottom: 16, left: 0, right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(images.length, (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentPage == index ? 12 : 8,
                                    height: _currentPage == index ? 12 : 8,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == index ? Colors.white : Colors.white54),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Listing Type Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(widget.property['title'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listingType.toUpperCase(), 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text(widget.property['city'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('₹${widget.property['price_per_month']}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  Text(priceLabel, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  
                  const SizedBox(height: 24),

                  // --- FEATURE GRID ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _featureItem(Icons.bed, '${widget.property['bedrooms']}', 'Beds'),
                        _verticalDivider(),
                        _featureItem(Icons.bathtub, '${widget.property['bathrooms']}', 'Baths'),
                        _verticalDivider(),
                        _featureItem(Icons.apartment, widget.property['property_type'] ?? 'N/A', 'Type'),
                        _verticalDivider(),
                        _featureItem(Icons.chair, widget.property['furnishing'] ?? 'N/A', 'Furnish'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.property['description'] ?? 'No description provided.', style: const TextStyle(height: 1.5, fontSize: 15)),
                  
                  const SizedBox(height: 32),
                  
                  // --- ACTION BUTTONS ---
                  if (listingType != 'buy')
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.assignment_turned_in),
                        label: const Text('Request to Rent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final uid = supabase.auth.currentUser!.id;
                          if (widget.property['owner_id'] == uid) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You own this property!')));
                            return;
                          }
                          final ctrl = TextEditingController();
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Send Request'),
                              content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Message to owner...')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await RentalRequestService.submitRequest(propertyId: widget.property['id'], ownerId: widget.property['owner_id'], message: ctrl.text.trim());
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent!')));
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity, height: 55,
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message Owner', style: TextStyle(fontSize: 16)),
                      onPressed: () async {
                        final ownerId = widget.property['owner_id'];
                        final uid = supabase.auth.currentUser!.id;
                        if (ownerId == uid) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You own this property!')));
                          return;
                        }
                        final convoId = await MessageService.getOrCreateConversation(propertyId: widget.property['id'], ownerId: ownerId);
                        if (!mounted) return;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversationId: convoId, otherName: 'Owner')));
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.build, size: 18),
                          label: const Text('Maintenance'),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: _showMaintenanceDialog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.flag, size: 18, color: Colors.red),
                          label: const Text('Report', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () async {
                            final ctrl = TextEditingController();
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Report Listing'),
                                content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Why are you reporting this?')),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await supabase.from('reports').insert({'property_id': widget.property['id'], 'reporter_id': supabase.auth.currentUser!.id, 'reason': ctrl.text.trim()});
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 48),
                  ReviewsSection(propertyId: widget.property['id']),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3));
  }
}