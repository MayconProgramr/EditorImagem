import 'package:flutter/material.dart';

class TextView extends StatefulWidget {
  final double left;
  final double top;
  final Function ontap;
  final Function(DragUpdateDetails) onpanupdate;
  final double fontsize;
  final String value;
  final TextAlign align;
  final Color fontColor;
  const TextView({Key key, this.left, this.top, this.ontap, this.onpanupdate, this.fontsize, this.value, this.align, this.fontColor}) : super(key: key);
  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  @override
  Widget build(BuildContext context) {
    return  Positioned(
                            left: widget.left,
                            top: widget.top,
                            child: GestureDetector(
                                onTap: widget.ontap,
                                onPanUpdate: widget.onpanupdate,
                                child: Text(widget.value,
                                textAlign: widget.align,
                                    style: TextStyle(
                                      fontSize: widget.fontsize,
                                      color: widget.fontColor
                                    ))),
                          );
  }
}