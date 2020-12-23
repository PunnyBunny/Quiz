import 'package:flutter/material.dart';

void pushInstructionPage(BuildContext context, List<Widget> children) {
  Navigator.push(context, MaterialPageRoute(builder: (_) {
    return InstructionPage(children);
  }));
}

class InstructionPage extends StatelessWidget {
  List<Widget> children;
  bool _initiated = false;

  InstructionPage(this.children);

  @override
  Widget build(BuildContext context) {
    if (!_initiated) {
      _init(context);
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  void _init(BuildContext context) {
    final title = Text(
      '香港中學生粵語語義能力測試',
      style: Theme.of(context).textTheme.headline5,
      textAlign: TextAlign.center,
    );
    final back = ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.blue),
      child: Text('知道'),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    final padding = Padding(padding: EdgeInsets.all(20.0));

    children = <Widget>[title, padding] + children + <Widget>[padding, back];
    _initiated = true;
  }
}
