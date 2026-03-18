# sim_card_info

A Flutter plugin to get SIM card information.

## Features

- Fetches SIM card information from the device.
- Handles exceptions and returns appropriate messages.

## Getting Started

### Installation

Add `sim_card_info` to your `pubspec.yaml` file:

```yaml
dependencies:
  sim_card_info: ^1.0.0

```

then run `flutter pub get` in your terminal.

## Usage

### Import

```dart
import 'package:sim_card_info/sim_card_info.dart';
```

### Get SIM card information

```dart
final _simCardInfoPlugin = SimCardInfo();
List<SimInfo>? _simInfo;

// Retrieve SIM card information
simCardInfo = await _simCardInfoPlugin.getSimInfo() ?? [];
```

### Handling Exceptions
In cases where retrieving information fails, especially on certain devices like iOS, utilize a try/catch block with a `PlatformException`:

```dart
  Future<void> initSimInfoState() async {
  List<SimInfo>? simCardInfo;
  // Platform messages may fail, so we use a try/catch PlatformException.
  // We also handle the message potentially returning null.
  try {
    simCardInfo = await _simCardInfoPlugin.getSimInfo() ?? [];
  } on PlatformException {
    simCardInfo = [];
    setState(() {
      isSupported = false;
    });
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  if (!mounted) return;
  setState(() {
    _simInfo = simCardInfo;
  });
}
```


## Permissions
refer to `example` directory for a complete sample app using`sim_card_info` plugin.

## Issues and feedback
For any issue or feedback please [create an issue](https://github.com/FadyFouad/sim_card_info/issues/new).


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.