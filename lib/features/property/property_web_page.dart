import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class PropertyWebPage extends StatefulWidget {
  const PropertyWebPage({super.key, required this.url});
  final String? url;

  @override
  State<PropertyWebPage> createState() => _PropertyWebPageState();
}

class _PropertyWebPageState extends State<PropertyWebPage> {
  late final WebViewController _controller;
  double _progress = 0;
  String? _error;

  static const _chromeMobileUA =
      'Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/125.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_chromeMobileUA)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100),
          onWebResourceError: (err) => setState(() => _error = err.description),
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    final initial = widget.url;
    if (initial != null && initial.isNotEmpty) {
      _controller.loadRequest(Uri.parse(initial));
    } else {
      _error = 'Invalid URL';
    }

    if (!kIsWeb && Platform.isAndroid) {
      final androidCtrl = _controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(true);
      androidCtrl.setMediaPlaybackRequiresUserGesture(false);

      final cookieManager = AndroidWebViewCookieManager(
        const PlatformWebViewCookieManagerCreationParams(),
      );
      cookieManager.setAcceptThirdPartyCookies(androidCtrl, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Details'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            onPressed: (url.isEmpty)
                ? null
                : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new),
          ),
          IconButton(
            tooltip: 'Reload',
            onPressed: _error == null ? () => _controller.reload() : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: (_progress > 0 && _progress < 1)
              ? LinearProgressIndicator(value: _progress, minHeight: 3)
              : const SizedBox.shrink(),
        ),
      ),
      body: _error != null
          ? _ErrorView(message: _error!)
          : WebViewWidget(controller: _controller),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
