import 'package:flutter/material.dart';

class KeepAlivePageWrapper extends StatefulWidget {
  const KeepAlivePageWrapper(
      {super.key, required this.child, this.keepAlive = true});

  final Widget child;
  final bool keepAlive;

  @override
  State<KeepAlivePageWrapper> createState() => _KeepAlivePageWrapperState();
}

class _KeepAlivePageWrapperState extends State<KeepAlivePageWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
