import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with TickerProviderStateMixin {
  late AnimationController scaleController;
  late AnimationController rotateController;
  late Animation scale;
  late Animation rotate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scaleController = AnimationController(vsync: this,duration: Duration(seconds: 1))..addListener(() {
      setState(() {});
    })..repeat(reverse: true);
    rotateController = AnimationController(vsync: this,duration: Duration(seconds: 1))..addListener(() {
      setState(() {});
    })..repeat();
    scale = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: scaleController, curve: Curves.linear));
    rotate = Tween(begin: 0.0,end: 360.0).animate(CurvedAnimation(parent: rotateController, curve: Curves.linear));
  }

  @override
  void dispose() {
    super.dispose();
    scaleController.dispose();
    rotateController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        scaleController.dispose();
        rotateController.dispose();
        return true;
      },
      child: Scaffold(
        body: Center(
          child: Transform.rotate(
            angle: rotate.value * 0.0174533,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.0-scale.value,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.orange,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: scale.value,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
