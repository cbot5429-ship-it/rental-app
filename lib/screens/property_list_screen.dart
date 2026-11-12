import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_filter.dart';
import '../services/property_query_service.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/property_card.dart';
import 'compare_screen.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  final String initialQuery;
  final String listingType;
  const PropertyListScreen({super.key, required this.initialQuery, required this.listingType});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  List<Map<String, dynamic>> _properties = [];
  bool _loading = true;
  late PropertyFilter _filter;
  List<Map<String, dynamic>> _compareList = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialQuery;
    _filter = PropertyFilter()
      ..listingType = widget.listingType
      ..searchQuery = widget.initialQuery;
    _load();
    _saveSearch(widget.initialQuery);
  }

  Future<void> _saveSearch(String query) async {
    if (query.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_search', query);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _filter.searchQuery = _searchCtrl.text;
    final data = await PropertyQueryService.search(_filter);
    if (mounted) setState(() { _properties = data; _loading = false; });
  }

  Future<void> _openFilters() async {
    final result = await showFilterSheet(context, _filter);
    if (result != null) {
      setState(() => _filter = result);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            _load();
            _saveSearch(_searchCtrl.text);
          },
          decoration: InputDecoration(
            hintText: 'Search locality, name or pincode...',
            filled: true,
            fillColor: Colors.grey.shade100,
            prefixIcon: const Icon(Icons.search, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _filter.activeCount > 0,
              label: Text('${_filter.activeCount}'),
              child: const Icon(Icons.tune),
            ),
            onPressed: _openFilters,
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _compareList.isNotEmpty,
              label: Text('${_compareList.length}'),
              child: const Icon(Icons.compare_arrows),
            ),
            onPressed: () {
              if (_compareList.length >= 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CompareScreen(properties: _compareList)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least 2 to compare.')));
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? const Center(child: Text('No properties match your search.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  itemCount: _properties.length,
                  itemBuilder: (context, i) {
                    final p = _properties[i];
                    final isSelected = _compareList.any((e) => e['id'] == p['id']);
                    
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          if (isSelected) {
                            _compareList.removeWhere((e) => e['id'] == p['id']);
                          } else {
                            if (_compareList.length < 3) _compareList.add(p);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected ? Border.all(color: Colors.green, width: 3) : null,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: PropertyCard(
                          property: p,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p))),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}