import 'package:flutter/material.dart';

class TypeAheadField extends StatefulWidget {
  const TypeAheadField({
    Key? key,
    this.options,
    this.inputKey, 
    this.inputController, 
    this.inputDecoration,
    this.onFocusCallback,
    this.onChangedCallback,
    this.onSubmittedCallback,
    this.onSuggestionSelected
  }) : super(key: key);   

  final List<String>? options;
  final Key? inputKey;
  final TextEditingController? inputController;
  final InputDecoration? inputDecoration;
  final Function()? onFocusCallback;
  final Function(String)? onChangedCallback;
  final Function(String)? onSubmittedCallback;
  final Function(String)? onSuggestionSelected;

  @override
  _TypeAheadFieldState createState() => _TypeAheadFieldState();
}

class _TypeAheadFieldState extends State<TypeAheadField> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.onFocusCallback!();
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _overlayEntry?.remove();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    final List<Widget> optionWidgets = [];
    int optionsLength = widget.options?.length as int;
    if (widget.options != null && optionsLength > 0) {
      for (int i = 0; i < optionsLength; i++) {
        final Widget option = InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
            child: Text(widget.options?[i] as String)
          ),
          onTap: () {
            widget.onSuggestionSelected!(widget.options?[i] as String); 
          }
        );
        optionWidgets.add(option);
      }
    } else {
      final Widget noItemsFound = Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Center(
          child: Text('No items found')
        )
      );
      optionWidgets.add(noItemsFound);
    }
    double height = 160.0;
    if (optionWidgets.length < 5) {
      height = optionWidgets.length * 32.0;
    }

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: Container(
              height: height,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    children: optionWidgets
                  )
                ),
              )
            )
          )
        )
      )
    );
  }

  void _afterLayout(_) {
    if (_overlayEntry != null && _focusNode.hasFocus) {
      _overlayEntry?.remove();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }  
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        focusNode: _focusNode,
        key: widget.inputKey,
        controller: widget.inputController,
        decoration: widget.inputDecoration,
        onChanged: widget.onChangedCallback,
        onFieldSubmitted: widget.onSubmittedCallback
      ),
    );
  }
}