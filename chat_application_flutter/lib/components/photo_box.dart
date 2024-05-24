import 'package:flutter/material.dart';

class PhotoBox extends StatelessWidget {
  final Widget child;
  const PhotoBox({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
           BoxShadow(
              color: Colors.grey.shade300, blurRadius: 5, offset:const Offset(-2, -2)),
        ]),
    padding: EdgeInsets.all(10),
    child: child,
  );
  }
}

