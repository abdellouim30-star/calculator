import 'package:flutter/material.dart';

void main() => runApp(const CalcApp());

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const Calc(),
      );
}

class Calc extends StatefulWidget {
  const Calc({super.key});
  @override
  State<Calc> createState() => _CalcState();
}

class _CalcState extends State<Calc> {
  String display = '0';
  double? first;
  String? op;
  bool fresh = true;

  String fmt(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
  }

  double calc() {
    final b = double.tryParse(display) ?? 0;
    final a = first ?? b;
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  void press(String k) {
    setState(() {
      if (display == 'Error' && k != 'C') return;
      if ('0123456789'.contains(k)) {
        display = (fresh || display == '0') ? k : display + k;
        fresh = false;
      } else if (k == '.') {
        if (fresh) {
          display = '0.';
          fresh = false;
        } else if (!display.contains('.')) {
          display += '.';
        }
      } else if (k == 'C') {
        display = '0';
        first = null;
        op = null;
        fresh = true;
      } else if (k == '⌫') {
        if (!fresh) {
          if (display.length <= 1 || (display.length == 2 && display.startsWith('-'))) {
            display = '0';
          } else {
            display = display.substring(0, display.length - 1);
          }
        }
      } else if (k == '±') {
        if (display != '0') {
          display = display.startsWith('-') ? display.substring(1) : '-$display';
        }
      } else if (k == '%') {
        display = fmt((double.tryParse(display) ?? 0) / 100);
        fresh = true;
      } else if (k == '=') {
        if (op != null) {
          display = fmt(calc());
          first = null;
          op = null;
          fresh = true;
        }
      } else {
        if (op != null && !fresh) {
          display = fmt(calc());
        }
        first = double.tryParse(display);
        op = k;
        fresh = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['⌫', '0', '.', '='],
    ];
    const ops = ['÷', '×', '-', '+', '='];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  child: Text(
                    display,
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
            for (final r in rows)
              Row(
                children: [
                  for (final k in r)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SizedBox(
                          height: 72,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: ops.contains(k) ? Colors.orange : Colors.grey.shade800,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () => press(k),
                            child: Text(k, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
