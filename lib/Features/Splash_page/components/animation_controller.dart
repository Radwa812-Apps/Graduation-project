import 'package:flutter/material.dart';

class SplashAnimationController {
  late final AnimationController _controller;
  late final Animation<double> scaleAnimation;
  late final Animation<double> translateYAnimation;

  int repeatCount = 3;
  int currentRepeat = 0;

  
  final VoidCallback onAnimationComplete;

  SplashAnimationController(TickerProvider vsync, this.onAnimationComplete) {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: vsync,
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    translateYAnimation = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        currentRepeat++;
        if (currentRepeat < repeatCount) {
          _controller.reverse();
        } else {
          _controller.stop();  
          onAnimationComplete(); 
        }
      }
      if (status == AnimationStatus.dismissed && currentRepeat < repeatCount) {
        _controller.forward();
      }
    });

    _controller.forward();  
  }

 
  AnimationController get controller => _controller;

  void dispose() {
    _controller.dispose();
  }
}
