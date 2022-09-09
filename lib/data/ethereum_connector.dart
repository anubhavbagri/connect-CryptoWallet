import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_test/data/repo/wallet_connector.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WalletConnectEthereumCredentials extends CustomTransactionSender {
  WalletConnectEthereumCredentials({required this.provider});

  final EthereumWalletConnectProvider provider;

  @override
  Future<EthereumAddress> extractAddress() {
    throw UnimplementedError();
  }

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final hash = await provider.sendTransaction(
      from: transaction.from!.hex,
      to: transaction.to?.hex,
      data: transaction.data,
      gas: transaction.maxGas,
      gasPrice: transaction.gasPrice?.getInWei,
      value: transaction.value?.getInWei,
      nonce: transaction.nonce,
    );

    return hash;
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    throw UnimplementedError();
  }
}

class EthereumConnector implements WalletConnector {
  String? _uri;
  late final WalletConnect _connector;
  late final EthereumWalletConnectProvider _provider;

  EthereumConnector() {
    _connector = WalletConnect(
      // bridge: Making a bride between our app to metamask application
      bridge: 'https://bridge.walletconnect.org',
      // clientMeta: while we are connecting our app to metamask we are showing some details to metamask application.
      // i.e. which application is going to access your wallet.
      clientMeta: const PeerMeta(
        name: 'Demo ETH',
        description: 'Demo ETH Application',
        // url: we will provide url to do a transaction from walletConnect.
        // if you don’t provide url our app will be connected to metamask but we cannot do payments.
        url: 'https://walletconnect.org',
        // icons : showing the icon of app in metamask wallet while connecting.
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );

    // EthereumWalletConnectProvider : A provider implementation to easily support the Ethereum blockchain.
    _provider = EthereumWalletConnectProvider(_connector);
  }

  // Connect to a new session.
  @override
  Future<SessionStatus?> connect() async {
    if (_connector.connected) {
      return SessionStatus(
        chainId: _connector.session.chainId,
        accounts: _connector.session.accounts,
      );
    }

    //pass the chain id of a network. 137 is Polygon
    return await _createSession(chainId: 137);
  }

  // Register callback listeners.
  // [onConnect] is triggered when session is connected.
  // [onSessionUpdate] is triggered when session is updated.
  // [onDisconnect] is triggered when session is disconnected.
  @override
  void registerListeners(
    OnConnectRequest? onConnect,
    OnSessionUpdate? onSessionUpdate,
    OnDisconnect? onDisconnect,
  ) =>
      _connector.registerListeners(
        onConnect: onConnect,
        onSessionUpdate: onSessionUpdate,
        onDisconnect: onDisconnect,
      );

  Future<SessionStatus?> _createSession({
    int? chainId,
  }) async {
    try {
      final session = await _connector.createSession(
          chainId: chainId,
          onDisplayUri: (uri) async {
            _uri = uri;
            launchUrl(Uri.parse(uri));
          });
      return session;
    } catch (e) {
      print(e);
      // rethrow;
    }
    return null;
  }

  @override
  Future<String?> sendAmount({
    required String recipientAddress,
    required double amount,
  }) async {
    final sender = EthereumAddress.fromHex(_connector.session.accounts[0]);
    final recipient = EthereumAddress.fromHex(address);

    // Ethereum.fromUnitAndValue() : This Constructs an amount of Ether by a unit and its amount.
    // [amount] can either be a base10 string, an int, or a BigInt.
    final etherAmount = EtherAmount.fromUnitAndValue(
        EtherUnit.szabo, (amount * 1000 * 1000).toInt());

    final transaction = Transaction(
      to: recipient,
      from: sender,
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 100000,
      value: etherAmount,
    );

    final credentials = WalletConnectEthereumCredentials(provider: _provider);

    try {
      final txBytes = await _ethereum.sendTransaction(credentials, transaction);
      return txBytes;
    } catch (e) {
      print('Error: $e');
    }

    killSession();

    return null;
  }

  // Kill the current session with [sessionError].
  Future<void> killSession({String? sessionError}) async =>
      await _connector.killSession(sessionError: sessionError);

  // Try to open Wallet selected during session creation.
  // For iOS will try to open previously selected Wallet
  // For Android will open system dialog
  @override
  Future<void> openWalletApp() async {
    if (_uri == null) return;
    await launchUrl(Uri.parse(_uri!));
  }

  @override
  Future<double> getBalance() async {
    final address = EthereumAddress.fromHex(_connector.session.accounts[0]);
    final amount = await _ethereum.getBalance(address);
    return amount.getValueInUnit(EtherUnit.ether).toDouble();
  }

  @override
  bool validateAddress({required String address}) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  String get faucetUrl => 'https://faucet.polygon.technology/';

  @override
  String get address => _connector.session.accounts[0];

  @override
  String get coinName => 'Eth';

  final _ethereum = Web3Client(
    'https://polygon-mumbai.g.alchemy.com/v2/YLZl8yIoPQo0T1b7sFLHsERXuqbCflDX',
    Client(),
  );
}
