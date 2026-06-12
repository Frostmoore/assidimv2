import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 270,
      child: Stack(
        alignment: const Alignment(-1, -1),
        children: [
          Row(
            children: [
              Expanded(
                child: Image.network(
                  constants.IMG_PATH + config.headerAgenzia,
                  height: 200,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
          Positioned(
            top: 130,
            left: width / 2 - 70,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              child: Material(
                elevation: 10,
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                child: CircleAvatar(
                  radius: 68,
                  backgroundImage: NetworkImage(
                    constants.IMG_PATH + config.logoAgenzia,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
