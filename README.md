## Wallet_test

Connect with any web3/crypto wallet that supports [WalletConnect](https://walletconnect.com/) and transact through the flutter application.

> Here, we are using Ethereum based [polygon](https://polygon.technology/) chain (Mumbai Testnet)

- Replace **faucetUrl** and **RPC** API endpoint if you want to use any other chain:

```dart
@override
  String get faucetUrl => 'https://faucet.polygon.technology/';
```

```dart
// Using Web3Client for sending requests over an HTTP JSON-RPC API endpoint to Ethereum.
final _ethereum = Web3Client(
    'https://polygon-mumbai.g.alchemy.com/v2/YLZl8yIoPQo0T1b7sFLHsERXuqbCflDX',
    Client(),
  );
```
