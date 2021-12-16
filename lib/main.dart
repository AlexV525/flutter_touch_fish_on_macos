///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/12/16 22:34
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Touch fish on macOS',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  /// UI configurations.
  final BorderRadius _radius = BorderRadius.circular(10);

  /// Period configurations.
  Duration get _waitingDuration => const Duration(seconds: 5);

  List<Duration> get _periodDurations {
    return <Duration>[
      const Duration(seconds: 5),
      const Duration(seconds: 10),
      const Duration(seconds: 4),
      const Duration(seconds: 7),
      const Duration(seconds: 1),
    ];
  }

  int get currentPeriod => _currentPeriod.value;
  final ValueNotifier<int> _currentPeriod = ValueNotifier<int>(1);

  set currentPeriod(int value) => _currentPeriod.value = value;

  @override
  void initState() {
    super.initState();
    Future.delayed(_waitingDuration).then((_) => _callAnimation());
  }

  @override
  void reassemble() {
    super.reassemble();
    _controller
      ..stop()
      ..reset();
    currentPeriod = 0;
    Future.delayed(_waitingDuration).then((_) => _callAnimation());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _callAnimation() async {
    final Duration _currentDuration = _periodDurations[currentPeriod];
    currentPeriod++;
    final Duration? _nextDuration =
        currentPeriod < _periodDurations.length ? _periodDurations.last : null;
    final double target = currentPeriod / _periodDurations.length;
    await _controller.animateTo(target, duration: _currentDuration);
    if (_nextDuration == null) {
      currentPeriod = 0;
      return;
    }
    await _callAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: Image.asset(
                'assets/apple-logo.png',
                color: CupertinoColors.white,
                width: 100,
              ),
            ),
            Expanded(
              child: Container(
                width: 200,
                alignment: Alignment.topCenter,
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPeriod,
                  builder: (_, int period, __) {
                    if (period == 0) {
                      return const SizedBox.shrink();
                    }
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey),
                        borderRadius: _radius,
                      ),
                      child: ClipRRect(
                        borderRadius: _radius,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _controller.value,
                            backgroundColor: CupertinoColors.lightBackgroundGray
                                .withOpacity(.3),
                            color: CupertinoColors.white,
                            minHeight: 5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
