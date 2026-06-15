import 'dart:convert';

class Q7b {
  const Q7b({
    required this.t,
    required this.p,
    required this.n,
    required this.l,
  });

  final String t;
  final String p;
  final String n;
  final List<Uri> l;
}

class Q7 {
  const Q7._();

  static const String _a0 = 'RGlnaXRhbCBJZGVudGl0eQ==';
  static const String _a1 = 'QnVpbHQgYnk=';
  static const String _a2 = 'RGFyaW5lbCBFc2NvYmFy';
  static const String _a3 = 'aHR0cHM6Ly9naXRodWIuY29tL0RhcmluZWxFc2NvYmFy';
  static const String _a4 =
      'aHR0cHM6Ly93d3cubGlua2VkaW4uY29tL2luL2RhcmluZWxlc2NvYmFy';

  static const String _b0 = String.fromEnvironment(
    'K2_0_B64',
    defaultValue: _a0,
  );
  static const String _b1 = String.fromEnvironment(
    'K2_1_B64',
    defaultValue: _a1,
  );
  static const String _b2 = String.fromEnvironment(
    'K2_2_B64',
    defaultValue: _a2,
  );
  static const String _b3 = String.fromEnvironment(
    'K2_3_B64',
    defaultValue: _a3,
  );
  static const String _b4 = String.fromEnvironment(
    'K2_4_B64',
    defaultValue: _a4,
  );

  static Q7b get v {
    return Q7b(
      t: _d(_b0, _a0),
      p: _d(_b1, _a1),
      n: _d(_b2, _a2),
      l: <Uri>[Uri.parse(_d(_b3, _a3)), Uri.parse(_d(_b4, _a4))],
    );
  }

  static String _d(String v, String f) {
    final x = v.trim().isEmpty ? f : v;
    try {
      return utf8.decode(base64.decode(x));
    } on FormatException {
      return utf8.decode(base64.decode(f));
    }
  }
}
