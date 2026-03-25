import 'dart:async';

import 'package:natrix/src/writer.dart';

const List<String> spin = ["⣄", "⣠", "⠸", "⠙", "⠋", "⠇"];
Future<void> main(List<String> args) async {
  final NatrixOutputWriter writer = NatrixOutputWriter();
  // final NatrixMountpoint barMount = writer.newLine();
  // writer.setLine(mount: barMount, text: "░" * 20);
  final NatrixMountpoint mount = writer.newLine();
  int n = 0;
  writer.setLine(mount: mount, text: "Retrieve status information ${spin[n]}");
  for (int i = 0; i < 40; i++) {
    await Future.delayed(Duration(milliseconds: 125));
    // writer.setLine(mount: barMount, text: "▓" * (i/4).round() + "░" * (20 - (i/4).round()));
    writer.setLine(
      mount: mount,
      text: "Retrieve status information ${spin[n++ >= 5 ? n = 0 : n]}",
    );
  }
  writer.setLine(mount: mount);
  writer.setLine(mount: mount, text: "An error occurred. Retry...");
  await Future.delayed(Duration(milliseconds: 1500));
  writer.setLine(mount: mount);
  for (int i = 0; i < 40; i++) {
    await Future.delayed(Duration(milliseconds: 125));
    // writer.setLine(mount: barMount, text: "▓" * (i/4).round() + "░" * (20 - (i/4).round()));
    writer.setLine(
      mount: mount,
      text: "Retrieve status information ${spin[n++ >= 5 ? n = 0 : n]}",
    );
  }
  writer.setLine(mount: mount, text: "Status is OK.");
}
