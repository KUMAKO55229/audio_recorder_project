import 'package:audio_recorder_project/managers/services_manager/services_manager.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShazamAnimationScreen extends StatefulWidget {
  @override
  _ShazamAnimationScreenState createState() => _ShazamAnimationScreenState();
}

class _ShazamAnimationScreenState extends State<ShazamAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesManager>(builder: (_, servicesManager, __) {
      return Scaffold(
        backgroundColor: Color(0xFF042442),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Tap to Shazam',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(
                  height: 40,
                ),
                AvatarGlow(
                  endRadius: 200.0,
                  animate: servicesManager.isRecognizing,
                  child: GestureDetector(
                    onTap: () => servicesManager.isRecognizing
                        ? servicesManager.stopRecognizing()
                        : servicesManager.startRecognizing(),
                    child: Material(
                      shape: CircleBorder(),
                      elevation: 8,
                      child: Container(
                        padding: EdgeInsets.all(40),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF089af8)),
                        child: Image.asset(
                          'assets/images/shazam-logo.png',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      );
    });
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Shazam Animation'),
    //   ),
    //   body: Center(
    //     child: AnimatedBuilder(
    //       animation: _scaleAnimation,
    //       builder: (context, child) {
    //         return Transform.scale(
    //           scale: _scaleAnimation.value,
    //           child: child,
    //         );
    //       },
    //       child: Image.asset('assets/images/sound-icon.jpg'),
    //     ),
    //   ),
    // );
  }
}
