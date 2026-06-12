import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({super.key});

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(
        'https://www.hybridandgogsv.it/denuncia_sinistro.php?id=' +
            constants.ID +
            "&token=" +
            constants.TOKEN));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(constants.TITOLO_FORM_DENUNCIA),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
