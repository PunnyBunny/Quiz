import 'package:flutter/material.dart';

void pushInstructionPage(BuildContext context, List<Widget> children) {
  Navigator.push(context, MaterialPageRoute(builder: (_) {
    return InstructionPage(children: children);
  }));
}

class InstructionPage extends StatelessWidget {
  final List<Widget> children;

  const InstructionPage({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = Padding(padding: EdgeInsets.all(20.0));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_title(context), padding] +
              children +
              [padding, _backButton(context)],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      '香港中學生粵語語義能力測試',
      style: Theme.of(context).textTheme.headline5,
      textAlign: TextAlign.center,
    );
  }

  Widget _backButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.blue),
      child: Text('知道'),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
