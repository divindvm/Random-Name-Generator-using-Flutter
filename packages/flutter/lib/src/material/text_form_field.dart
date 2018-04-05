// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'input_decorator.dart';
import 'text_field.dart';
import 'theme.dart';

/// A [FormField] that contains a [TextField].
///
/// This is a convenience widget that wraps a [TextField] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// When a [controller] is specified, it can be used to control the text being
/// edited. Its content will be overwritten by [initialValue] (which defaults
/// to the empty string) on creation and when [reset] is called.
///
/// For a documentation about the various parameters, see [TextField].
///
/// See also:
///
///  * <https://material.google.com/components/text-fields.html>
///  * [TextField], which is the underlying text field without the [Form]
///    integration.
///  * [InputDecorator], which shows the labels and other visual elements that
///    surround the actual text editing widget.
class TextFormField extends FormField<String> {
  /// Creates a [FormField] that contains a [TextField].
  ///
  /// When a [controller] is specified, it can be used to control the text
  /// being edited. Its content will be overwritten by [initialValue] (which
  /// defaults to the empty string) on creation and when [reset] is called.
  ///
  /// For documentation about the various parameters, see the [TextField] class
  /// and [new TextField], the constructor.
  TextFormField({
    Key key,
    this.controller,
    String initialValue: '',
    FocusNode focusNode,
    InputDecoration decoration: const InputDecoration(),
    TextInputType keyboardType: TextInputType.text,
    TextStyle style,
    TextAlign textAlign: TextAlign.start,
    bool autofocus: false,
    bool obscureText: false,
    bool autocorrect: true,
    int maxLines: 1,
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
    List<TextInputFormatter> inputFormatters,
  }) : assert(initialValue != null),
       assert(keyboardType != null),
       assert(textAlign != null),
       assert(autofocus != null),
       assert(obscureText != null),
       assert(autocorrect != null),
       assert(maxLines == null || maxLines > 0),
       super(
    key: key,
    initialValue: initialValue,
    onSaved: onSaved,
    validator: validator,
    builder: (FormFieldState<String> field) {
      final _TextFormFieldState state = field;
      final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration())
        .applyDefaults(Theme.of(field.context).inputDecorationTheme);
      return new TextField(
        controller: state._effectiveController,
        focusNode: focusNode,
        decoration: effectiveDecoration.copyWith(errorText: field.errorText),
        keyboardType: keyboardType,
        style: style,
        textAlign: textAlign,
        autofocus: autofocus,
        obscureText: obscureText,
        autocorrect: autocorrect,
        maxLines: maxLines,
        onChanged: field.onChanged,
        onSubmitted: onFieldSubmitted,
        inputFormatters: inputFormatters,
      );
    },
  );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController controller;

  @override
  _TextFormFieldState createState() => new _TextFormFieldState();
}

class _TextFormFieldState extends FormFieldState<String> {
  TextEditingController _controller;

  TextEditingController get _effectiveController => widget.controller ?? _controller;

  @override
  TextFormField get widget => super.widget;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = new TextEditingController(text: widget.initialValue);
    } else {
      widget.controller.text = widget.initialValue;
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(TextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null)
        _controller = new TextEditingController.fromValue(oldWidget.controller.value);
      if (widget.controller != null) {
        setValue(widget.controller.text);
        if (oldWidget.controller == null)
          _controller = null;
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.text = widget.initialValue;
    });
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value)
      onChanged(_effectiveController.text);
  }
}
