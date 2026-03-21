import 'package:natrix/natrix.dart';
import 'package:natrix/src/runner.dart';

Future<void> main(final List<String> args) async {
  final NatrixPipeline pipeline = NatrixPipeline(
    arguments: args,
    stencil: ConfigurableNatrixStencil(

    ),
  );
  await pipeline.run(
    Command(
      short: "",
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
