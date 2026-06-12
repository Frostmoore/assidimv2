import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/core/providers/app_provider.dart';

class GearMenu extends StatelessWidget {
  const GearMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const HtmlWidget(
                '<h1 style="text-align:left;">IL MIO ACCOUNT</h1>'),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<String>(
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: Icon(Icons.settings),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'logout',
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: Icon(Icons.logout),
                      ),
                      Text('Log-out'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AppProvider>().logout();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
