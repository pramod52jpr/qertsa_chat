import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  final String image;
  final String tag;
  const ImageFullScreen({super.key, required this.image, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: tag,
                child: Image.network(image,fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back),
                ),
              ),
            )
          ]
        ),
      ),
    );
  }
}
