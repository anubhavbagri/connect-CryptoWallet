import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet_test/data/ethereum_connector.dart';
import 'package:wallet_test/data/repo/wallet_connector.dart';
import 'package:wallet_test/views/wallet.dart';
import 'package:wallet_test/views/wallet_created.dart';
import 'package:web3dart/web3dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/crypto.dart';

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  connectionFailed,
  connectionCancelled,
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Credentials cred;
  late EthereumAddress address;
  EtherAmount? balance;
  // late final SharedPreferences _prefs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  WalletConnector connector = EthereumConnector();
  ConnectionState _state = ConnectionState.disconnected;

  @override
  void initState() {
    connector.registerListeners((session) => print('Connected: $session'),
        (response) => print('Session updated: $response'), () {
      setState(
        () => _state = ConnectionState.disconnected,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Connection Test'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  child: Text(
                    'Connect to the Ethereum account through WalletConnect.',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: _transactionStateToAction(state: _state),
                  child: Text(
                    _transactionStateToString(state: _state),
                  ),
                ),
                ElevatedButton(
                  onPressed: createWallet,
                  child: Text(
                    "Create Wallet",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _transactionStateToString({required ConnectionState state}) {
    switch (state) {
      case ConnectionState.disconnected:
        return 'Connect!';
      case ConnectionState.connecting:
        return 'Connecting';
      case ConnectionState.connected:
        return 'Session connected';
      case ConnectionState.connectionFailed:
        return 'Connection failed';
      case ConnectionState.connectionCancelled:
        return 'Connection cancelled';
    }
  }

  VoidCallback? _transactionStateToAction({required ConnectionState state}) {
    print('State: ${_transactionStateToString(state: state)}');
    switch (state) {
      case ConnectionState.connecting:
        return null;
      case ConnectionState.connected:
        return () => _openWalletPage();

      case ConnectionState.disconnected:
      case ConnectionState.connectionCancelled:
      case ConnectionState.connectionFailed:
        return () async {
          setState(() => _state = ConnectionState.connecting);
          try {
            final session = await connector.connect();
            if (session != null) {
              setState(() => _state = ConnectionState.connected);
              Future.delayed(Duration.zero, () => _openWalletPage());
            } else {
              setState(() => _state = ConnectionState.connectionCancelled);
            }
          } catch (e) {
            setState(() => _state = ConnectionState.connectionFailed);
          }
        };
    }
  }

  void _openWalletPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WalletPage(connector: connector),
      ),
    );
  }

  void _openCreatedWalletPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WalletCreatedPage(connector: connector),
      ),
    );
  }

  void createWallet() async {
    cred = generateRandomAccount();
    address = await cred.extractAddress();
    cred.extractAddress();
    print(address);
    _openCreatedWalletPage();
  }

  //GENERATE RANDOM WALLET
  Credentials generateRandomAccount() {
    // print(Random.secure());
    final cred = EthPrivateKey.createRandom(Random.secure());

    final key = bytesToHex(
      cred.privateKey,
      padToEvenLength: true,
    );

    setPrivateKey(key);

    return cred;
  }

  void setPrivateKey(key) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('privateKey', key);
  }

  void getPrivateKey(key) async {
    final SharedPreferences prefs = await _prefs;
    prefs.getString('privateKey') ?? '';
  }
}
