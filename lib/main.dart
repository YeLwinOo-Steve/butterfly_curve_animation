import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

late final FlutterView view;
Duration? begin;

void beginFrame(Duration timeStamp) {
  final Rect paintBounds =
      Offset.zero & (view.physicalSize / view.devicePixelRatio);
  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas = Canvas(recorder, paintBounds);
  canvas.translate(paintBounds.width / 2.0, paintBounds.height / 2.0);
  canvas.drawPaint(Paint()..color = const Color(0x00000000));
  begin ??= timeStamp;

  final double t =
      double.parse(((timeStamp - begin!).inMilliseconds).toStringAsFixed(1));

  for (int i = 50; i > 0; i--) {
    /// butterfly curve equation
    double x = -sin(i * t) * (pow(e, cos(i * t)) - 2 * cos(4 * i * t));
    double y = -cos(i * t) * (pow(e, cos(i * t)) - 2 * cos(4 * i * t));

    canvas.drawCircle(
      /// offset of circle
      Offset(paintBounds.width * x / 8.0, paintBounds.height * y / 8.0),

      /// random radius starts from 2 to 6
      Random().nextInt(4) + 2,

      /// random color
      Paint()
        ..color = Color.fromARGB(255, Random().nextInt(205) + i,
            Random().nextInt(205) + i, Random().nextInt(205) + i),
    );
  }

  final Picture picture = recorder.endRecording();

  final double devicePixelRatio = view.devicePixelRatio;
  final Float64List deviceTransform = Float64List(16)
    ..[0] = devicePixelRatio
    ..[5] = devicePixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;
  final SceneBuilder sceneBuilder = SceneBuilder()
    ..pushTransform(deviceTransform)
    ..addPicture(Offset.zero, picture)
    ..pop();
  view.render(sceneBuilder.build());

  PlatformDispatcher.instance.scheduleFrame();
}

void main() {
  assert(PlatformDispatcher.instance.implicitView != null);
  view = PlatformDispatcher.instance.implicitView!;

  PlatformDispatcher.instance
    ..onBeginFrame = beginFrame
    ..scheduleFrame();
}
