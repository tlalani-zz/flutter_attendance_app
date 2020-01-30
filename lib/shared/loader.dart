import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'constants.dart';

class Loader extends StatelessWidget {
  final LoaderType type;
  const Loader({Key key, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: getLoader(),
        ),
    );
  }

  Widget getLoader() {
    if (this.type == LoaderType.CubeGrid)
      return SpinKitCubeGrid(color: Colors.teal[400], size: 45);
    else if (this.type == LoaderType.ChasingDots)
      return SpinKitChasingDots(color: Colors.teal[400]);
    else if (this.type == LoaderType.SquareCircle)
      return SpinKitSquareCircle(color: Colors.teal[400]);
    else if (this.type == LoaderType.WanderingCubes)
      return SpinKitWanderingCubes(color: Colors.teal[400]);
    else if (this.type == LoaderType.ThreeBounce)
      return SpinKitThreeBounce(color: Colors.teal[400]);
    else if (this.type == LoaderType.Wave)
      return SpinKitWave(color: Colors.teal[400]);
    else
      return SpinKitCubeGrid(color: Colors.teal[400]);
  }
}
