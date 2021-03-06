import 'package:flutter/material.dart';
import 'package:word_soup/models/custom_fab_props.dart';

class WordSelectionBox extends StatelessWidget {

  final String selection;
  final double margin1 = 8;
  final double margin2 = 5;

  const WordSelectionBox({Key key, this.selection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.all(margin1),
      decoration: BoxDecoration(
        color: CustomFabProps.COMMON_COLOR,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 0.8,
          )
        ]
      ),
      child: Center(
        child: Text(
          selection,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'MavenPro',
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: selection.length > 30 ? 16 : 25
          ),
        ),
      ),
    );
  }
}
