import 'package:flutter/material.dart';

void main() {
  runApp(const RootWidget());
}

class RootWidget extends StatefulWidget {
  const RootWidget({Key? key}) : super(key: key);
  @override
  SelectThePicturePage createState() => SelectThePicturePage();
}

class SelectThePicturePage extends State<RootWidget> {
  Widget currentWidgetBeingDisplayed = Text("ImageWillBeDisplayedHere");

  void openTheImageSelectorWindowUsingWindowsExplorer() {
    setState(() {
      currentWidgetBeingDisplayed = ExplorerPageWidgetForSelectingTheImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(children: <Widget>[
        ElevatedButton(
            onPressed: openTheImageSelectorWindowUsingWindowsExplorer,
            child: Text("Select Image")),
        currentWidgetBeingDisplayed
      ]),
    );
  }
}

class ExplorerPageWidgetForSelectingTheImage extends StatefulWidget {
  const ExplorerPageWidgetForSelectingTheImage({Key? key}) : super(key: key);

  @override
  StateOfExplorerPageWidgetForSelectingTheImage createState() =>
      StateOfExplorerPageWidgetForSelectingTheImage();
}

class StateOfExplorerPageWidgetForSelectingTheImage
    extends State<ExplorerPageWidgetForSelectingTheImage> {
  Widget build(BuildContext context) {
    return Container(child: Text("None"));
  }
}
