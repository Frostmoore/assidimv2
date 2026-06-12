import 'package:flutter/material.dart';
import 'package:Assidim/assets/constants.dart' as constants;

class Cai extends StatelessWidget {
  const Cai({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const Text(
          constants.TESTOCAI,
          textAlign: TextAlign.center,
        ),
        constants.SPACER,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => constants.openUrl(constants.CAI_LINK),
                label: const Text(constants.LABEL_BOTTONE_CAI),
                style: constants.STILE_BOTTONE,
                icon: const Icon(Icons.edit_document),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
