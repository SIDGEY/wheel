import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheel/utils/extensions.dart';
import 'package:wheel/wheel/wheel.dart';
import 'package:wheel/wheel/wheel_arrow.dart';
import 'package:wheel/wheel/wheel_pivot.dart';

import 'fireworks/foundation/controller.dart';
import 'fireworks/widgets/fireworks.dart';
import 'generated/l10n.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final soundStateProvider = StateProvider<bool>((ref) => false);


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Wheel",
      onGenerateTitle: (context) => S.current.appName,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),

      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates:  const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      home: const FortuneWheelPage(),
    );
  }
}

class FortuneWheelPage extends ConsumerStatefulWidget {
  const FortuneWheelPage({super.key});

  @override
  FortuneWheelPageState createState() => FortuneWheelPageState();
}

class FortuneWheelPageState extends ConsumerState<FortuneWheelPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late final FireworkController _controllerFireworks;
  final _random = Random();
  final AudioPlayer player = AudioPlayer();
  final AssetSource wheelMP3Path = AssetSource("audios/wheel.mp3");
  final AssetSource applauseMP3Path = AssetSource("audios/applause.mp3");
  final AssetSource fireworksound = AssetSource('audios/firework.mp3');
  List<String> _items = List.empty(growable: true);


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );
    _controllerFireworks = FireworkController(vsync: this)
      ..start()
      ..autoLaunchDuration = Duration.zero
      ..rocketSpawnTimeout = Duration.zero
      ..explosionParticleCount = 1000
      ..title = ' ';
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerFireworks.dispose();
    player.dispose();
    super.dispose();
  }

  void _startRotation() {
    if(ref.read(soundStateProvider)){
      playSound(wheelMP3Path);
    }

    int randomIndex = Random().nextInt(_items.length);
    const double fullRotation = 2 * pi;
    final double anglePerItem = fullRotation / _items.length;
    final double targetAngle = fullRotation - (randomIndex * anglePerItem);
    final int numberOfExtraRotations = Random().nextInt(5) + 5;
    final double extraRotationAngle = numberOfExtraRotations * fullRotation;

    final Tween<double> angleTween = Tween(begin: 0, end: targetAngle + extraRotationAngle);
    _animation = angleTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );
    _controller.reset();
    _controller.forward(from: 0).then((_) {
      int rocketCount = _random.nextInt(10) + 1; // Spawns between 1 and 10 rockets for better performance.
      for (int i = 0; i < rocketCount; i++) {
        Duration delay = Duration(milliseconds: _random.nextInt(1000));
        Future.delayed(delay, () {
          _controllerFireworks.spawnRocket(
            Point(
              _random.nextDouble() * _controllerFireworks.windowSize.width,
              _random.nextDouble() * _controllerFireworks.windowSize.height / 2,

            ),
            forceSpawn: true,
          );
          //need delay
          if(ref.read(soundStateProvider)) {
            player.play(fireworksound);
          }
        });
      }
      // Show the dialog
      _showWinnerDialog(randomIndex);
    });
  }

  void _showWinnerDialog(randomIndex) {

    if(ref.read(soundStateProvider)){
      playSound(applauseMP3Path);
    }


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('On a un gagnant !'),
        content: Text('Resto choisi : ${_items[randomIndex]}!'),
        actions: [
          TextButton(
            child: const Text('Thank you'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void playSound(AssetSource soundPath) async {
    await player.play(soundPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.text.appName),
        actions: [
          Consumer(builder: (context, ref, child) {
            final state =  ref.watch(soundStateProvider);
            return IconButton(onPressed: (){
                ref.watch(soundStateProvider.notifier).state = !state;
            }
            , icon: Icon(state ? Icons.volume_up: Icons.volume_off )
          ,);
          })
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (!_controller.isAnimating) {
            _startRotation();
          }
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Fireworks(controller: _controllerFireworks),
            FutureBuilder<List<String>>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      _items = snapshot.data!;
                      return Transform.rotate(
                        angle: _animation.value,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.height * 0.8 - 40,
                          height: MediaQuery.of(context).size.height * 0.8 - 40,
                          child: Wheel(_items),
                        ),
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            Positioned(
              bottom: 100,
              child: FilledButton(
                onPressed: () {
                  if (!_controller.isAnimating) {
                    _startRotation();
                  }
                },
                child:  Text(context.text.button_hangry),
              ),
            ),
            Positioned(
              child: SizedBox(
                width: MediaQuery.of(context).size.height * 0.8 - 40,
                height: MediaQuery.of(context).size.height * 0.8 - 40,
                child: const Arrow(),
              ),
            ),
            Positioned(
                child: SizedBox(
              width: MediaQuery.of(context).size.height * 0.8 - 40,
              height: MediaQuery.of(context).size.height * 0.8 - 40,
              child: const WheelPivot(),
            ))
          ],
        ),
      ),
    );
  }

  Future<List<String>> getData(){
    return Future.value(['McDo', 'Le plouc', 'Pizza hut', 'Dominos', 'BurgerKing', 'Sushi']);
  }

}
