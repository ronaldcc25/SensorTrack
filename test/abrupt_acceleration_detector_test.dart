import 'package:flutter_test/flutter_test.dart';
import 'package:taller_sensortrack/services/abrupt_acceleration_detector.dart';

void main() {
  group('AbruptAccelerationDetector', () {
    test('detecta una muestra cuya magnitud alcanza el umbral', () {
      final detector = AbruptAccelerationDetector();

      expect(detector.addSample(15, 0, 0), isTrue);
    });

    test('no repite la alerta hasta que la aceleración vuelva a bajar', () {
      final detector = AbruptAccelerationDetector();

      expect(detector.addSample(16, 0, 0), isTrue);
      expect(detector.addSample(18, 0, 0), isFalse);
      expect(
        detector.addSample(AbruptAccelerationDetector.rearmThresholdMps2, 0, 0),
        isFalse,
      );
      expect(detector.addSample(15, 0, 0), isTrue);
    });

    test('combina los ejes al calcular la magnitud', () {
      final detector = AbruptAccelerationDetector();

      expect(detector.addSample(11, 11, 0), isTrue);
    });
  });
}
