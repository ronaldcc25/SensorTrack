import 'dart:math' as math;

class AbruptAccelerationDetector {
  static const double thresholdMps2 = 15.0;
  static const double rearmThresholdMps2 = thresholdMps2 * 0.75;

  bool _aboveThreshold = false;

  bool addSample(double x, double y, double z) {
    final magnitude = magnitudeMps2(x, y, z);

    if (_aboveThreshold) {
      if (magnitude <= rearmThresholdMps2) {
        _aboveThreshold = false;
      }
      return false;
    }

    if (magnitude < thresholdMps2) return false;

    _aboveThreshold = true;
    return true;
  }

  void reset() {
    _aboveThreshold = false;
  }

  static double magnitudeMps2(double x, double y, double z) {
    return math.sqrt(x * x + y * y + z * z);
  }
}
