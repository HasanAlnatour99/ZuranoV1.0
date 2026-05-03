import 'package:flutter/material.dart';

class ZuranoSwipeShell extends StatefulWidget {
  const ZuranoSwipeShell({
    super.key,
    required this.pages,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.bottomNavigationBar,
    this.enableSwipe = true,
  });

  final List<Widget> pages;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget bottomNavigationBar;
  final bool enableSwipe;

  @override
  State<ZuranoSwipeShell> createState() => _ZuranoSwipeShellState();
}

class _ZuranoSwipeShellState extends State<ZuranoSwipeShell> {
  late final PageController _pageController;
  bool _isSyncingFromExternalIndex = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(covariant ZuranoSwipeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == oldWidget.currentIndex) {
      return;
    }
    if (!_pageController.hasClients) {
      return;
    }
    final page = _pageController.page?.round();
    if (page == widget.currentIndex) {
      return;
    }
    _isSyncingFromExternalIndex = true;
    _pageController.jumpToPage(widget.currentIndex);
    _isSyncingFromExternalIndex = false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: widget.enableSwipe
            ? const PageScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        pageSnapping: true,
        onPageChanged: (index) {
          if (_isSyncingFromExternalIndex || index == widget.currentIndex) {
            return;
          }
          widget.onIndexChanged(index);
        },
        children: widget.pages,
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
