# Frankencoin Wallet: A Ethereum Wallet for Frankecoin

This GitHub repository contains the source code for the Ethereum wallet specifically designed for storing and managing
ZCHF, the Frankencoin stablecoin pegged to the Swiss Franc (CHF).

## What is Frankencoin (ZCHF)?

Frankencoin (ZCHF) is an Ethereum-based (ERC-20) stablecoin that is pegged 1:1 to the Swiss Franc (CHF).
It offers a price-stable alternative to traditional cryptocurrencies while leveraging the security and transparency of
the Ethereum blockchain.

## Features

- ZCHF-Specific: Designed and optimized for storing and managing ZCHF and FPS tokens.
- Secure Storage: Stores private keys securely on your device using industry-standard encryption methods.
- Easy to Use: User-friendly interface for sending, receiving, and managing ZCHF tokens.
- Transparency: Leverages the transparency of the Ethereum blockchain for all transactions.

## Install

- Ensure Flutter SDK is installed:
Flutter includes the Dart SDK, so you don't need to install Dart separately if you have Flutter installed. If Flutter is not yet installed, follow the instructions for your operating system from the [official Flutter installation guide](https://docs.flutter.dev/get-started/install)
- If you're using iOS and Mac, install bundler and ruby dependencies
```bash
gem install bundler && bundle install
```
- Generate translation files
```bash
dart tool/generate_localization.dart
```
- Run Build Runner
```bash
dart run build_runner build --delete-conflicting-outputs
```
- Copy empty secrets
```bash
echo "const walletConnectProjectId = \"\";" > lib/secrets.g.dart
```

- Open simulator to be detected by flutter
```bash
open -a Simulator
```

- Get Flutter dependencies:
```bash
flutter pub get
```
- Run the Flutter app:
```bash
flutter run
```

## Contributing

We welcome contributions from the community! If you find a bug or have a new feature suggestion, please create an issue
on this repository.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Disclaimer

The use of this wallet is at your own risk. The developers take no responsibility for any loss of funds due to user
error, hacking, or other unforeseen circumstances. It is important to always be cautious when dealing with
cryptocurrencies and take appropriate security measures.
