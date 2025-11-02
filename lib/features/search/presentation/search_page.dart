import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/autocomplete_item.dart';
import '../../../models/search_criteria.dart';
import 'search_controller.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    final q = _controller.text.trim();
    final suggestions = ref.watch(structuredSuggestionsProvider(q));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const Text('Search', style: TextStyle(color: Colors.black87)),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F1FF),
                Color(0xFFD6E4F0),
                Color(0xFFBFD7ED),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search by hotel, street, city or country',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.black12.withOpacity(0.06)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.black12.withOpacity(0.06)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.lightBlue.shade300, width: 1.2),
                      ),
                    ),
                    onSubmitted: (_) {},
                  ),
                ),
                Expanded(
                  child: suggestions.when(
                    loading: () => const _LoadingList(),
                    error: (e, _) => _ErrorView(message: e.toString()),
                    data: (list) => list.isEmpty
                        ? const _EmptyView()
                        : _GroupedSuggestionList(
                      items: list,
                      onPick: (item) {
                        final now = DateTime.now();
                        final cIn = now.add(const Duration(days: 3));
                        final cOut = now.add(const Duration(days: 4));
                        final criteria = SearchCriteria(
                          checkIn: cIn.toIso8601String().substring(0, 10),
                          checkOut: cOut.toIso8601String().substring(0, 10),
                          searchType: item.type,
                          searchQuery: item.query,
                          rooms: 1,
                          adults: 2,
                          children: 0,
                          currency: 'INR',
                          limit: 10,
                        );
                        context.pushNamed('results', extra: criteria);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _LoadingList extends StatelessWidget {
  const _LoadingList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, __) => const ListTile(
        leading: CircleAvatar(radius: 18),
        title: LinearProgressIndicator(minHeight: 10),
        subtitle: SizedBox(height: 8),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: 6,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Start typing to see suggestions',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.error_outline, size: 42),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}

class _GroupedSuggestionList extends StatelessWidget {
  const _GroupedSuggestionList({required this.items, required this.onPick});
  final List<AutoCompleteItem> items;
  final ValueChanged<AutoCompleteItem> onPick;

  IconData _iconFor(String group) {
    switch (group) {
      case 'byPropertyName':
        return Icons.apartment;
      case 'byStreet':
        return Icons.map_outlined;
      case 'byCity':
        return Icons.location_city;
      case 'byState':
        return Icons.map;
      case 'byCountry':
        return Icons.public;
      default:
        return Icons.search;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<AutoCompleteItem>>{};
    for (final it in items) {
      (groups[it.group] ??= []).add(it);
    }

    final orderedKeys = ['byPropertyName', 'byStreet', 'byCity', 'byState', 'byCountry']
        .where((k) => groups[k]?.isNotEmpty == true)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: orderedKeys.length,
      itemBuilder: (context, idx) {
        final key = orderedKeys[idx];
        final list = groups[key]!;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                dense: true,
                leading: Icon(_iconFor(key)),
                title: Text(
                  key.replaceFirst('by', ''),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Divider(height: 0),
              ...list.map((it) => ListTile(
                leading: const Icon(Icons.search),
                title: Text(it.display, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: _subtitle(it),
                onTap: () => onPick(it),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget? _subtitle(AutoCompleteItem it) {
    final bits = [it.city, it.state, it.country].where((e) => e != null && e!.isNotEmpty).cast<String>().toList();
    if (bits.isEmpty) return null;
    return Text(bits.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
