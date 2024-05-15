import 'package:flutter/material.dart';

class SelectPlaceAction extends StatelessWidget {
  final String locationName;
  final String tapToSelectActionText;
  final VoidCallback onTap;

  const SelectPlaceAction(this.locationName, this.onTap, this.tapToSelectActionText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(locationName, style: const TextStyle(fontSize: 16)),
                    Text(tapToSelectActionText, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward)
            ],
          ),
        ),
      ),
    );
  }
}
