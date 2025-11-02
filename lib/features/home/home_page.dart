import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_travaly/features/home/popular_stays_provider.dart';

import '../../common/widgets/shimmer_tile.dart';
import '../search/widgets/property_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.refresh(popularStaysProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final popular = ref.watch(popularStaysProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _confirmExit();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          title: const Text('MyTravaly – Hotels'),
          actions: [
            IconButton(
              onPressed: _refresh,
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () => context.pushNamed('search'),
              tooltip: 'Search',
              icon: const Icon(Icons.search),
            ),
          ],
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              backgroundBlendMode: BlendMode.lighten,
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: popular.when(
                  loading: () => ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, __) => const ShimmerTile(),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: 6,
                  ),
                  error: (e, _) => ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 24),
                      const Icon(Icons.error_outline, size: 42),
                      const SizedBox(height: 12),
                      Text(e.toString(), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Center(
                        child: FilledButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                  data: (items) => ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => PropertyCard(
                      hotel: items[i],
                      onTap: () {
                        final url = items[i].propertyUrl ?? items[i].imageUrl;
                        print("url is $url");
                        if (url != null && url.isNotEmpty) {
                          context.pushNamed('propertyWeb', extra: url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Link not available for this property',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit MyTravaly?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      if (Platform.isAndroid) {
        exit(0);
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }
}
