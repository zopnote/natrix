import 'package:natrix/natrix.dart';

Future<void> main(final List<String> args) async {
  final NatrixPipeline pipeline = NatrixPipeline(arguments: args);
  await pipeline.run(
    Command(
      intro: "",
      description: "",
      flags: const [
        TextFlag(name: "test"),
        BoolFlag(name: "", value: false),
      ],
      hidden: true,
      run: (info) => const Response(),
    ),
  );
}
