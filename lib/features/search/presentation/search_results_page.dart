import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/hotel.dart';
import '../../../models/search_criteria.dart';
import 'search_controller.dart';
import 'search_controller.dart' show searchPagingProvider;
import '../widgets/property_card.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key});
  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels > _scrollCtrl.position.maxScrollExtent - 300) {
        ref.read(searchPagingProvider.notifier).fetchNext();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is SearchCriteria) {
        ref.read(searchPagingProvider.notifier).resetWithCriteria(extra);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchPagingProvider, (_, next) {
      if (next.error && next.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message!)));
      }
    });

    final paging = ref.watch(searchPagingProvider);

    final extra = GoRouterState.of(context).extra;
    final title = (extra is SearchCriteria)
        ? _titleFromCriteria(extra)
        : 'Results';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          if (extra is SearchCriteria) _CriteriaChips(criteria: extra),
          Expanded(
            child: ListView.separated(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: paging.items.length + (paging.loading || paging.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                if (i < paging.items.length) {
                  return PropertyCard(
                    hotel: paging.items[i],
                    onTap: () {
                      final url = paging.items[i].propertyUrl ?? paging.items[i].imageUrl;
                      if (url != null && url.isNotEmpty) {
                        context.pushNamed('propertyWeb', extra: url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link not available for this property')),
                        );
                      }
                    },
                  );
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),

          SizedBox(height: 50,)
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (extra is SearchCriteria) {
            ref.read(searchPagingProvider.notifier).resetWithCriteria(extra);
          }
        },
        label: const Text('Reload'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  String _titleFromCriteria(SearchCriteria c) {
    switch (c.searchType) {
      case 'hotelIdSearch':
        return 'Matching Properties';
      case 'citySearch':
        return 'Stays in ${c.searchQuery.first}';
      case 'streetSearch':
        return 'Nearby: ${c.searchQuery.first}';
      case 'countrySearch':
        return 'Stays in ${c.searchQuery.first}';
      default:
        return 'Results';
    }
  }
}

class _CriteriaChips extends StatelessWidget {
  const _CriteriaChips({required this.criteria});
  final SearchCriteria criteria;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _chip(Icons.date_range, '${criteria.checkIn} → ${criteria.checkOut}', style),
          _chip(Icons.people, '${criteria.adults} Adults${criteria.children > 0 ? ', ${criteria.children} Children' : ''}', style),
          _chip(Icons.meeting_room, '${criteria.rooms} Room(s)', style),
          _chip(Icons.currency_rupee, criteria.currency, style),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, TextStyle? style) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text, style: style),
      backgroundColor: Colors.black.withOpacity(.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
