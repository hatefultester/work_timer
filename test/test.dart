import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {

  test('ever', () async {
    final count = false.obs;
    dynamic result = -1;
    final worker = everAll([count], (value) {
      result = value;
    });
    count.toggle();
    await Future.delayed(Duration.zero);
    expect(true, result);
    count.toggle();
    await Future.delayed(Duration.zero);
    expect(false, result);
    worker.dispose();
    count.toggle();
    await Future.delayed(Duration.zero);
    expect(false, result);
  });
}
