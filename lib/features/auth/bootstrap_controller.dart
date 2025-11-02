import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../search/data/search_repository.dart';
import '../search/presentation/search_controller.dart';

final visitorTokenProvider = StateProvider<String?>((_) => null);

class BootstrapState {
  final bool loading;
  final String? error;
  final bool done;
  const BootstrapState({this.loading = false, this.error, this.done = false});

  BootstrapState copyWith({bool? loading, String? error, bool? done}) =>
      BootstrapState(loading: loading ?? this.loading, error: error, done: done ?? this.done);
}

final appBootstrapProvider =
StateNotifierProvider<AppBootstrapController, BootstrapState>((ref) {
  final repo = SearchRepository(ref.read(dioClientProvider));
  return AppBootstrapController(ref, repo);
});

class AppBootstrapController extends StateNotifier<BootstrapState> {
  AppBootstrapController(this.ref, this.repo) : super(const BootstrapState());
  final Ref ref;
  final SearchRepository repo;

  Future<void> init() async {
    if (state.loading || state.done) return;
    state = state.copyWith(loading: true, error: null);

    try {
      //  Register device
      final token = await repo.registerDevice(
        deviceModel: 'RMX3521',
        deviceFingerprint:
        'realme/RMX3521/RE54E2L1:13/RKQ1.211119.001/S.f1bb32-7f7fa_1:user/release-keys',
        deviceBrand: 'realme',
        deviceId: 'RE54E2L1',
        deviceName: 'RMX3521_11_C.10',
        deviceManufacturer: 'realme',
        deviceProduct: 'RMX3521',
        deviceSerialNumber: 'unknown',
      );
      ref.read(visitorTokenProvider.notifier).state = token;

      // App settings
      final settings = await repo.appSettings();
      ref.read(appSettingsProvider.notifier).state = settings;

      //  Currency list
      final currencies = await repo.currencyList(visitorToken: token, baseCode: 'INR');
      ref.read(currencyListProvider.notifier).state = currencies;

      state = state.copyWith(loading: false, done: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final appSettingsProvider = StateProvider<Map<String, dynamic>>((_) => {});
final currencyListProvider = StateProvider<List<Map<String, dynamic>>>((_) => []);
