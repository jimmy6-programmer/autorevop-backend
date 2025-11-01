import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget adaptiveButton(String text, VoidCallback? onPressed, {bool isLoading = false, bool isEnabled = true}) {
  final effectiveOnPressed = isEnabled ? onPressed : null;
  return Platform.isIOS
      ? _IOSButton(text: text, onPressed: effectiveOnPressed, isLoading: isLoading)
      : _AndroidButton(text: text, onPressed: effectiveOnPressed, isLoading: isLoading);
}

class _IOSButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _IOSButton({required this.text, required this.onPressed, this.isLoading = false});

  @override
  _IOSButtonState createState() => _IOSButtonState();
}

class _IOSButtonState extends State<_IOSButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _scale = 0.95);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _scale = 1.0);
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.onPressed != null
                ? LinearGradient(
                    colors: [Color.fromRGBO(17, 131, 192, 1), Color.fromRGBO(106, 27, 154, 1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey, Colors.grey], // Greyed out when disabled
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CupertinoButton.filled(
            onPressed: widget.isLoading ? null : widget.onPressed, // Disable when loading
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            borderRadius: BorderRadius.circular(25),
            child: widget.isLoading
                ? CupertinoActivityIndicator(color: Colors.white)
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.onPressed != null ? Colors.white : Colors.grey.shade400, // Grey text when disabled
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AndroidButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _AndroidButton({required this.text, required this.onPressed, this.isLoading = false});

  @override
  _AndroidButtonState createState() => _AndroidButtonState();
}

class _AndroidButtonState extends State<_AndroidButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _scale = 0.95);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _scale = 1.0);
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.onPressed != null
                ? LinearGradient(
                    colors: [Color.fromRGBO(17, 131, 192, 1), Color.fromRGBO(106, 27, 154, 1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey, Colors.grey], // Greyed out when disabled
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed, // Disable when loading
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: Colors.transparent,
              foregroundColor: widget.onPressed != null ? Colors.white : Colors.grey.shade400, // Grey text when disabled
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: widget.isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.onPressed != null ? Colors.white : Colors.grey.shade400, // Grey text when disabled
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}