import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../auth/bootstrap_controller.dart';
import '../search/data/search_repository.dart';
import '../../models/hotel.dart';

final dioClientProvider = Provider((ref) => DioClient.create());
final searchRepositoryProvider = Provider((ref) => SearchRepository(ref.read(dioClientProvider)));

final popularStaysProvider = FutureProvider.autoDispose<List<Hotel>>((ref) async {
  final token = ref.watch(visitorTokenProvider) ?? '';
  if (token.isEmpty) return [];

  final repo = ref.read(searchRepositoryProvider);

  return repo.propertyList(
    visitorToken: token,
    limit: 10,
    entityType: 'Any',
    searchType: 'byCity',
    country: 'India',
    state: 'Maharashtra',
    city: 'Mumbai',
    currency: 'INR',
  );
});
