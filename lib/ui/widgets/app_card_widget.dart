import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  AppCard({
    Key? key,
    this.child = const SizedBox.shrink()
  }) : super(key: key);  

  Widget _showCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: child
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showCard();
  }
}
