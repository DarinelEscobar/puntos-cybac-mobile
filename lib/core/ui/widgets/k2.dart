import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/q7.dart';

typedef K2x = Future<bool> Function(Uri uri);

class K2 extends StatefulWidget {
  const K2({
    super.key,
    required this.child,
    required this.x,
    this.d = const Duration(seconds: 4),
  });

  final Widget child;
  final K2x x;
  final Duration d;

  @override
  State<K2> createState() => _K2State();
}

class _K2State extends State<K2> {
  final Set<int> _p = <int>{};
  Timer? _t;
  bool _v = false;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _down(PointerDownEvent e) {
    _p.add(e.pointer);
    _arm();
  }

  void _end(PointerEvent e) {
    _p.remove(e.pointer);
    if (_p.length < 3) {
      _t?.cancel();
      _t = null;
    }
  }

  void _arm() {
    if (_v || _p.length < 3 || _t != null) {
      return;
    }

    _t = Timer(widget.d, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _v = true;
      });
      _t = null;
    });
  }

  void _hide() {
    setState(() {
      _v = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _down,
      onPointerUp: _end,
      onPointerCancel: _end,
      child: Stack(
        children: [
          widget.child,
          if (_v)
            Positioned.fill(
              child: SafeArea(
                minimum: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: _K2Panel(v: Q7.v, c: _hide, o: widget.x),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _K2Panel extends StatelessWidget {
  const _K2Panel({required this.v, required this.c, required this.o});

  final Q7b v;
  final VoidCallback c;
  final K2x o;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: v.t,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Material(
          color: Colors.white,
          elevation: 8,
          shadowColor: const Color(0x260F172A),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.t,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: c,
                      radius: 18,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: Color(0xFF64748B),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${v.p} ${v.n}',
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                for (final u in v.l) ...[
                  _K2Link(u: u, o: o),
                  if (u != v.l.last) const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _K2Link extends StatelessWidget {
  const _K2Link({required this.u, required this.o});

  final Uri u;
  final K2x o;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: () => o(u),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(7),
            color: const Color(0xFFF8FAFC),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              u.toString(),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 11,
                height: 1.25,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
