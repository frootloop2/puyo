import 'package:appengine/appengine.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

main() async {
  await runAppEngine((request) => io.handleRequest(
      request, createStaticHandler('./build', defaultDocument: 'index.html')));
}
