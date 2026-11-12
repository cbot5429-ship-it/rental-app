import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart' show supabase;
import '../services/image_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});
  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bedsCtrl = TextEditingController();
  final _bathsCtrl = TextEditingController();

  String? _type;
  String? _furnishing;
  String? _listingType = 'rent'; // Default
  List<XFile> _images = [];
  bool _loading = false;

  Future<void> _pickImages() async {
    final picked = await ImageService.pickMultiple();
    if (picked.isNotEmpty) setState(() => _images.addAll(picked));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one image')));
      return;
    }

    setState(() => _loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final imageUrls = await ImageService.uploadAll(_images, uid);

      await supabase.from('properties').insert({
        'owner_id': uid,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'price_per_month': double.parse(_priceCtrl.text.trim()),
        'bedrooms': int.parse(_bedsCtrl.text.trim()),
        'bathrooms': int.parse(_bathsCtrl.text.trim()),
        'property_type': _type,
        'furnishing': _furnishing,
        'listing_type': _listingType, // 👈 Save the Buy/Rent/Commercial type
        'images': imageUrls,
        'is_available': true,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Your Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Property Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._images.map((file) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FutureBuilder<Uint8List>(
                        future: file.readAsBytes(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox(width: 100);
                          return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(snap.data!, width: 100, height: 100, fit: BoxFit.cover));
                        },
                      ),
                    )),
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade400)),
                        child: const Icon(Icons.add_a_photo, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _listingType,
                decoration: const InputDecoration(labelText: 'Listing Type', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'buy', child: Text('For Sale (Buy)')),
                  DropdownMenuItem(value: 'rent', child: Text('For Rent')),
                  DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                ],
                onChanged: (v) => setState(() => _listingType = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'City / Locality', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()),
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bedsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Beds', border: OutlineInputBorder()),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bathsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Baths', border: OutlineInputBorder()),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Property Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
                        DropdownMenuItem(value: 'Gated Society', child: Text('Gated Society')),
                        DropdownMenuItem(value: 'Gated Community Villa', child: Text('Gated Community Villa')),
                        DropdownMenuItem(value: 'Independent House/Villa', child: Text('Independent House/Villa')),
                      ],
                      onChanged: (v) => setState(() => _type = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _furnishing,
                      decoration: const InputDecoration(labelText: 'Furnishing', border: OutlineInputBorder()),
                      items: ['furnished', 'semi', 'unfurnished'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
                      onChanged: (v) => setState(() => _furnishing = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), alignLabelWithHint: true),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Publish Listing', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}