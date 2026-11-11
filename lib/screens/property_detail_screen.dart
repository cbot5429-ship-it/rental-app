import '../services/rental_request_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../widgets/reviews_section.dart';
import '../main.dart' show supabase;
import '../services/message_service.dart';
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

  @override
  Widget build(BuildContext context) {
    // Using widget.property because it's a StatefulWidget now
    final images = (widget.property['images'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isEmpty
                  ? Container(color: Colors.grey.shade300, child: const Icon(Icons.home, size: 64))
                  : Stack(
                      children: [
                        // Image Carousel
                        PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (_, i) => Container(
                            color: Colors.black,
                            child: CachedNetworkImage(
                              imageUrl: images[i],
                              fit: BoxFit.contain,
                              memCacheWidth: 800,
                            ),
                          ),
                        ),
                        // Left Arrow
                        if (images.length > 1 && _currentPage > 0)
                          Positioned(
                            left: 8, top: 0, bottom: 0,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                                  onPressed: () => _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                ),
                              ),
                            ),
                          ),
                        // Right Arrow
                        if (images.length > 1 && _currentPage < images.length - 1)
                          Positioned(
                            right: 8, top: 0, bottom: 0,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                                  onPressed: () => _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                ),
                              ),
                            ),
                          ),
                        // Indicator Dots
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index ? Colors.white : Colors.white54,
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property['title'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.property['city'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${widget.property['price_per_month']} / month',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoChip(Icons.bed, '${widget.property['bedrooms']} Beds'),
                      _infoChip(Icons.bathtub, '${widget.property['bathrooms']} Baths'),
                      _infoChip(Icons.chair, widget.property['furnishing'] ?? 'N/A'),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.property['description'] ?? 'No description provided.', style: const TextStyle(height: 1.5)),
                  
                  const SizedBox(height: 24),
                  
                                    SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_turned_in),
                      label: const Text('Request to Rent'),
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
                          await RentalRequestService.submitRequest(
                            propertyId: widget.property['id'],
                            ownerId: widget.property['owner_id'],
                            message: ctrl.text.trim(),
                          );
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent!')));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // --- MESSAGE OWNER BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message Owner'),
                      onPressed: () async {
                        final ownerId = widget.property['owner_id'];
                        final uid = supabase.auth.currentUser!.id;
                        
                        if (ownerId == uid) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You own this property!')));
                          return;
                        }
                        
                        final convoId = await MessageService.getOrCreateConversation(
                          propertyId: widget.property['id'],
                          ownerId: ownerId,
                        );
                        
                        if (!mounted) return;
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChatScreen(conversationId: convoId, otherName: 'Owner'),
                        ));
                      },
                    ),
                  ),
                                    const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.flag, color: Colors.red),
                    label: const Text('Report this listing', style: TextStyle(color: Colors.red)),
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
                        await supabase.from('reports').insert({
                          'property_id': widget.property['id'],
                          'reporter_id': supabase.auth.currentUser!.id,
                          'reason': ctrl.text.trim(),
                        });
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you.')));
                      }
                    },
                  ),
                  
                  const Divider(height: 32),
                  
                  ReviewsSection(propertyId: widget.property['id']),
                  const SizedBox(height: 48), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}