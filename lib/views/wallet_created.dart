import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:wallet_test/data/repo/wallet_connector.dart';

class WalletCreatedPage extends StatelessWidget {
  const WalletCreatedPage({super.key, required WalletConnector connector});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 0.5),
            Text(
              'Wallet Created',
              style: Theme.of(context).textTheme.headline2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Data info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Public Address',
                        // style: Theme.of(context).textTheme.overline,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      SizedBox(height: 0.5),
                      Text(
                        '0x...',
                        style: Theme.of(context).textTheme.headline4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
