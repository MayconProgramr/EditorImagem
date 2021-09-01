import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_editor_pro/modules/all_emojies.dart';
import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/colors_picker.dart';
import 'package:image_editor_pro/modules/emoji.dart';
import 'package:image_editor_pro/modules/text.dart';
import 'package:image_editor_pro/modules/textview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
var width = 0.0;
var height = 0.0;

List fontsize = [];
List fontColor = [];
var howmuchwidgetis = 0;
var sliderDiscreteValue = 0.0;
List multiwidget = [];
Color currentcolors = Colors.white;
var opicity = 0.0;
var widthPen = 5.0;
Color pickerColor = Color(0xffB22222);
Color currentColor = Color(0xffB22222);

SignatureController _controller =
    SignatureController(penStrokeWidth: widthPen, penColor: Color(0xffB22222));
ScrollController _controllerSize;

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  _SliderIndicatorPainter(this.position);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(position, size.height / 2), 15, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;
  final File defaultImage;
  final Directory pathSave;
  final String nameSave;
  final Color backgroundScaffold;

  ImageEditorPro({
    this.appBarColor,
    this.bottomBarColor,
    this.defaultImage,
    this.pathSave,
    this.nameSave,
    this.backgroundScaffold = Colors.grey,
  });

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
  // create some values

  double _fontSize = 20.0;

  void _showFontSizePickerDialog() async {
    // <-- note the async keyword here

    // this will contain the result from Navigator.pop(context, result)
    final selectedFontSize = await showDialog<double>(
      context: context,
      builder: (context) => FontSizePickerDialog(),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (selectedFontSize != null) {
      setState(() {
        _fontSize = selectedFontSize;
      });
    }
  }

  // ValueChanged<Color> callback

  List<Offset> offsets = [];
  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  final scaf = GlobalKey<ScaffoldState>();
  var openbottomsheet = false;
  List<Offset> _points = <Offset>[];
  List type = [];
  List aligment = [];
  File _imageFile;
  final _sizeImage = GlobalKey();
  final GlobalKey globalKey = new GlobalKey();
  File _image;
  ScreenshotController screenshotController = ScreenshotController();
  Timer timeprediction;

  void timers() {
    Timer.periodic(Duration(milliseconds: 10), (tim) {
      setState(() {});
      timeprediction = tim;
    });
  }

  @override
  void dispose() {
    timeprediction.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    timers();
    _controller.clear();
    type.clear();
    fontsize.clear();
    fontColor.clear();
    offsets.clear();
    multiwidget.clear();
    howmuchwidgetis = 0;
    sliderDiscreteValue = 5;
    // TODO: implement initState
  }

  var _colorSig = Colors.orangeAccent.withOpacity(0.3);
  var _changeColor = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: widget.backgroundScaffold,
        key: scaf,
        appBar: new AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            new TextButton(
                child: new Text(
                  "Salvar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _imageFile = null;
                  screenshotController
                      .capture(
                          delay: Duration(milliseconds: 500), pixelRatio: 1.5)
                      .then((binaryIntList) async {
                    final paths =
                        widget.pathSave ?? await getTemporaryDirectory();
                    final name = widget.nameSave ??
                        DateTime.now().millisecondsSinceEpoch.toString();

                    print("local salvo: ${paths.path}");

                    final file =
                        await File('${paths.path}/' + name.toString() + '.jpg')
                            .create();
                    file.writeAsBytesSync(binaryIntList);

                    Navigator.pop(context, file);
                  }).catchError((onError) {
                    print(onError);
                  });
                }),
          ],
          backgroundColor: widget.appBarColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Flexible(
              child: Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Screenshot(
                  controller: screenshotController,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      widget.defaultImage != null
                          ? Image.file(
                              widget.defaultImage,
                              //fit: BoxFit.cover,
                            )
                          : Image.asset("assets/capa25463.jpeg"),
                      Positioned.fill(
                        child: RepaintBoundary(
                          key: globalKey,
                          child: Center(
                              child: GestureDetector(
                                  onPanUpdate: (DragUpdateDetails details) {
                                    setState(() {
                                      RenderBox object =
                                          context.findRenderObject();
                                      Offset _localPosition = object
                                          .globalToLocal(details.globalPosition);
                                      _points = new List.from(_points)
                                        ..add(_localPosition);
                                    });
                                  },
                                  onPanEnd: (DragEndDetails details) {
                                    _points.add(null);
                                  },
                                  child: Signature(
                                    controller: _controller,
                                    backgroundColor:
                                        Colors.transparent, // _colorSig
                                  ))),
                        ),
                      ),
                      /*TextButton(
                        child: Text('teste'),
                        onPressed: () {
                          setState(() {
                            if (!_changeColor) {
                              _colorSig = Colors.blueAccent.withOpacity(0.3);
                            } else {
                              _colorSig = Colors.orangeAccent.withOpacity(0.3);
                            }
                            _changeColor = !_changeColor;
                          });
                        }),*/
                      Positioned.fill(
                        child: Stack(
                          children: multiwidget.asMap().entries.map((f) {
                            return type[f.key] == 1
                                ? EmojiView(
                                    left: offsets[f.key].dx + 20,
                                    top: offsets[f.key].dy + 20,
                                    ontap: () {
                                      scaf.currentState
                                          .showBottomSheet((context) {
                                        return Sliders(
                                          size: f.key,
                                          sizevalue: fontsize[f.key].toDouble(),
                                          tipo: "emoji",
                                        );
                                      });
                                      setState(() {});
                                    },
                                    onpanupdate: (details) {
                                      setState(() {
                                        offsets[f.key] = Offset(
                                            offsets[f.key].dx + details.delta.dx,
                                            offsets[f.key].dy + details.delta.dy);
                                      });
                                    },
                                    value: f.value.toString(),
                                    fontsize: fontsize[f.key].toDouble(),
                                    align: TextAlign.center,
                                  )
                                : type[f.key] == 2
                                    ? TextView(
                                        left: offsets[f.key].dx + 20,
                                        top: offsets[f.key].dy + 20,
                                        ontap: () {
                                          scaf.currentState
                                              .showBottomSheet((context) {
                                            return Sliders(
                                              size: f.key,
                                              sizevalue:
                                                  fontsize[f.key].toDouble(),
                                              tipo: "texto",
                                            );
                                          });
                                        },
                                        onpanupdate: (details) {
                                          setState(() {
                                            offsets[f.key] = Offset(
                                                offsets[f.key].dx +
                                                    details.delta.dx,
                                                offsets[f.key].dy +
                                                    details.delta.dy);
                                          });
                                        },
                                        value: f.value.toString(),
                                        fontsize: fontsize[f.key].toDouble(),
                                        align: TextAlign.center,
                                        fontColor: fontColor[f.key],
                                      )
                                    : Container();
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
        bottomNavigationBar: openbottomsheet
            ? Container()
            : Container(
                padding: EdgeInsets.all(0.0),
                height: 80,
                alignment: AlignmentDirectional.center,
                color: widget.bottomBarColor,
                child: ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  buttonPadding: EdgeInsets.symmetric(horizontal: 5),
                  children: [
                    TextButton(
                      child: Column(
                        children: [
                          Icon(
                            FontAwesomeIcons.brush,
                            color: Colors.white,
                          ),
                          Text(
                            'Pintar',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onPressed: () {
                        _showFontSizePickerDialog();
                        /*showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Selecione uma cor'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ColorPicker(
                                      pickerColor: pickerColor,
                                      onColorChanged: changeColor,
                                      showLabel: false,
                                      pickerAreaHeightPercent: 0.8,
                                    ),
                                    Slider(
                                        value: sliderDiscreteValue,
                                        min: 0,
                                        max: 100,
                                        divisions: 5,
                                        label: sliderDiscreteValue.round().toString(),
                                        onChanged: (value) {
                                          setState(() {
                                            sliderDiscreteValue = value;
                                          });
                                          print('tamanho: ${sliderDiscreteValue}');
                                        },
                                      ),
                                  ],
                                )
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Ok'),
                                  onPressed: () {
                                    setState((){
                                      widthPen = 1.0;
                                      currentColor = pickerColor;                                      
                                      var points = _controller.points;
    _controller =
        SignatureController(penStrokeWidth: widthPen, penColor: currentColor, points: points);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });*/
                      },
                    ),
                    TextButton(
                      child: Column(
                        children: [
                          Icon(
                            Icons.text_fields,
                            color: Colors.white,
                          ),
                          Text(
                            'Texto',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onPressed: () async {
                        final value = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextEditor(
                                      appBarColor: widget.appBarColor,
                                      bottomColor: widget.bottomBarColor,
                                    )));
                        if (value.toString().isEmpty || value == null) {
                          //print("true");
                        } else {
                          type.add(2);
                          fontsize.add(30);
                          fontColor.add(Colors.black);
                          offsets.add(Offset.zero);
                          multiwidget.add(value);
                          howmuchwidgetis++;
                        }
                      },
                    ),
                    TextButton(
                      child: Column(
                        children: [
                          Icon(
                            FontAwesomeIcons.smile,
                            color: Colors.white,
                          ),
                          Text(
                            'Emoji',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onPressed: () {
                        Future getemojis = showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Emojies();
                            });
                        getemojis.then((value) {
                          if (value.toString().isEmpty || value == null) {
                            print("emoji vazio");
                          }else{
                            type.add(1);
                            fontsize.add(40);
                            offsets.add(Offset.zero);
                            fontColor.add(Colors.black);
                            multiwidget.add(value);
                            howmuchwidgetis++;
                          }
                        });
                      },
                    ),
                    TextButton(
                      child: Column(
                        children: [
                          Icon(
                            FontAwesomeIcons.eraser,
                            color: Colors.white,
                          ),
                          Text(
                            'Limpar',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onPressed: () {
                        _controller.clear();
                        type.clear();
                        fontsize.clear();
                        offsets.clear();
                        fontColor.clear();
                        multiwidget.clear();
                        howmuchwidgetis = 0;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              )), 
      onWillPop:  _willPopCallback);
  }

  Future<bool> _willPopCallback() async {
   // await showDialog or Show add banners or whatever
   // then
   return Future.value(true);
}

  final picker = ImagePicker();

  void bottomsheets() {
    openbottomsheet = true;
    setState(() {});
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return new Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(blurRadius: 10.9, color: Colors.grey[400])
          ]),
          height: 170,
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Text("Select Image Options"),
              ),
              Divider(
                height: 1,
              ),
              new Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.photo_library),
                                  onPressed: () async {
                                    var image = await picker.getImage(
                                        source: ImageSource.camera);
                                    var decodedImage =
                                        await decodeImageFromList(
                                            File(image.path).readAsBytesSync());

                                    setState(() {
                                      height = decodedImage.height as double;
                                      width = decodedImage.width as double;
                                      _image = File(image.path);
                                    });
                                    setState(() => _controller.clear());
                                    Navigator.pop(context);
                                  }),
                              SizedBox(width: 10),
                              Text("Open Gallery")
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () async {
                                  var image = await picker.getImage(
                                      source: ImageSource.gallery);
                                  var decodedImage = await decodeImageFromList(
                                      File(image.path).readAsBytesSync());

                                  setState(() {
                                    height = decodedImage.height as double;
                                    width = decodedImage.width as double;
                                    _image = File(image.path);
                                  });
                                  setState(() => _controller.clear());
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10),
                            Text("Open Camera")
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    openbottomsheet = false;
    setState(() {});
  }
}

class Signat extends StatefulWidget {
  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  @override
  void initState() {
    super.initState();
    //_controller.addListener(() => print("Value changed"));
  }

  @override
  Widget build(BuildContext context) {
    return //SIGNATURE CANVAS
        //SIGNATURE CANVAS
        ListView(
      children: <Widget>[
        Signature(
            controller: _controller,
            //height: height.toDouble(),
            //width: width.toDouble(),
            backgroundColor: Colors.transparent),
      ],
    );
  }
}

class Sliders extends StatefulWidget {
  final int size;
  final sizevalue;
  final String tipo;
  final double width;

  const Sliders(
      {Key key, this.size, this.sizevalue, this.tipo, this.width = 300})
      : super(key: key);

  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  final List<Color> _colors = [
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 128, 0),
    Color.fromARGB(255, 255, 255, 0),
    Color.fromARGB(255, 128, 255, 0),
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 0, 255, 128),
    Color.fromARGB(255, 0, 255, 255),
    Color.fromARGB(255, 0, 128, 255),
    Color.fromARGB(255, 0, 0, 255),
    Color.fromARGB(255, 127, 0, 255),
    Color.fromARGB(255, 255, 0, 255),
    Color.fromARGB(255, 255, 0, 127),
    Color.fromARGB(255, 128, 128, 128),
  ];

  double _colorSliderPosition = 0;
  double _shadeSliderPosition;
  Color _currentColor;
  Color _shadedColor;

  @override
  void initState() {
    slider = widget.sizevalue;
    // TODO: implement initState

    _currentColor = _calculateSelectedColor(_colorSliderPosition);
    _shadeSliderPosition = 0; //widget.width / 2; //center the shader selector
    _shadedColor = _calculateShadedColor(_shadeSliderPosition);

    super.initState();
  }

  _colorChangeHandler(double position) {
    //handle out of bounds positions
    if (position > widget.width) {
      position = widget.width;
    }
    if (position < 0) {
      position = 0;
    }
    //print("New pos: $position");
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      fontColor[widget.size] = _shadedColor;
    });
  }

  _shadeChangeHandler(double position) {
    //handle out of bounds gestures
    if (position > widget.width) position = widget.width;
    if (position < 0) position = 0;
    setState(() {
      _shadeSliderPosition = position;
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      fontColor[widget.size] = _shadedColor;
      //print("r: ${_shadedColor.red}, g: ${_shadedColor.green}, b: ${_shadedColor.blue}");
    });
  }

  Color _calculateShadedColor(double position) {
    double ratio = position / widget.width;
    if (ratio > 0.5) {
      //Calculate new color (values converge to 255 to make the color lighter)
      int redVal = _currentColor.red != 255
          ? (_currentColor.red +
                  (255 - _currentColor.red) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int greenVal = _currentColor.green != 255
          ? (_currentColor.green +
                  (255 - _currentColor.green) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int blueVal = _currentColor.blue != 255
          ? (_currentColor.blue +
                  (255 - _currentColor.blue) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else if (ratio < 0.5) {
      //Calculate new color (values converge to 0 to make the color darker)
      int redVal = _currentColor.red != 0
          ? (_currentColor.red * ratio / 0.5).round()
          : 0;
      int greenVal = _currentColor.green != 0
          ? (_currentColor.green * ratio / 0.5).round()
          : 0;
      int blueVal = _currentColor.blue != 0
          ? (_currentColor.blue * ratio / 0.5).round()
          : 0;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else {
      //return the base color
      return _currentColor;
    }
  }

  Color _calculateSelectedColor(double position) {
    //determine color
    double positionInColorArray =
        (position / widget.width * (_colors.length - 1));
    //print(positionInColorArray);
    int index = positionInColorArray.truncate();
    //print(index);
    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      _currentColor = _colors[index];
    } else {
      //calculate new color
      int redValue = _colors[index].red == _colors[index + 1].red
          ? _colors[index].red
          : (_colors[index].red +
                  (_colors[index + 1].red - _colors[index].red) * remainder)
              .round();
      int greenValue = _colors[index].green == _colors[index + 1].green
          ? _colors[index].green
          : (_colors[index].green +
                  (_colors[index + 1].green - _colors[index].green) * remainder)
              .round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
          ? _colors[index].blue
          : (_colors[index].blue +
                  (_colors[index + 1].blue - _colors[index].blue) * remainder)
              .round();
      _currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    return _currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.tipo != "emoji" ? 230 : 150,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Stack(
                children: [
                  Center(
                      child: Text(
                    widget.tipo != "emoji" ? "Cor e tamanho" : "Tamanho",
                    style: TextStyle(fontSize: 18),
                  )),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          fontsize[widget.size] = 0;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.delete,
                        size: 25,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                ],
              ),
            ),
            widget.tipo != "emoji"
                ? Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (DragStartDetails details) {
                        //print("_-------------------------STARTED DRAG");
                        _colorChangeHandler(details.localPosition.dx);
                      },
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        _colorChangeHandler(details.localPosition.dx);
                      },
                      onTapDown: (TapDownDetails details) {
                        _colorChangeHandler(details.localPosition.dx);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          width: widget.width,
                          height: 15,
                          decoration: BoxDecoration(
                            border:
                                Border.all(width: 1, color: Colors.grey[800]),
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(colors: _colors),
                          ),
                          child: CustomPaint(
                            painter:
                                _SliderIndicatorPainter(_colorSliderPosition),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            widget.tipo != "emoji"
                ? Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (DragStartDetails details) {
                        //print("_-------------------------STARTED DRAG");
                        _shadeChangeHandler(details.localPosition.dx);
                      },
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        _shadeChangeHandler(details.localPosition.dx);
                      },
                      onTapDown: (TapDownDetails details) {
                        _shadeChangeHandler(details.localPosition.dx);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          width: widget.width,
                          height: 15,
                          decoration: BoxDecoration(
                            border:
                                Border.all(width: 1, color: Colors.grey[800]),
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(colors: [
                              Colors.black,
                              _currentColor,
                              Colors.white
                            ]),
                          ),
                          child: CustomPaint(
                            painter:
                                _SliderIndicatorPainter(_shadeSliderPosition),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
            /*Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: _shadedColor,
            shape: BoxShape.circle,
          ),
        )*/
            ,
            SizedBox(height: 20),
            Slider(
                value: slider,
                min: 0.0,
                max: 100.0,
                onChangeEnd: (v) {
                  setState(() {
                    fontsize[widget.size] = v.toInt();
                  });
                },
                onChanged: (v) {
                  setState(() {
                    slider = v;
                    fontsize[widget.size] = v.toInt();
                  });
                }),
          ],
        ));
  }
}

class FontSizePickerDialog extends StatefulWidget {
  const FontSizePickerDialog({Key key}) : super(key: key);

  @override
  _FontSizePickerDialogState createState() => _FontSizePickerDialogState();
}

class _FontSizePickerDialogState extends State<FontSizePickerDialog> {
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    var points = _controller.points;
    _controller = SignatureController(
        penStrokeWidth: widthPen, penColor: color, points: points);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cor e tamanho'),
      content: SingleChildScrollView(
          child: Column(
        children: [
          ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            showLabel: false,
            pickerAreaHeightPercent: 0.8,
          ),
          Slider(
            value: sliderDiscreteValue,
            min: 1,
            max: 10,
            divisions: 9,
            label: sliderDiscreteValue.round().toString(),
            onChanged: (value) {
              setState(() {
                sliderDiscreteValue = value;
              });
            },
          ),
        ],
      )),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            setState(() {
              widthPen = sliderDiscreteValue;
              currentColor = pickerColor;
              var points = _controller.points;
              _controller = SignatureController(
                  penStrokeWidth: widthPen,
                  penColor: currentColor,
                  points: points);
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ColorPiskersSlider extends StatefulWidget {
  @override
  _ColorPiskersSliderState createState() => _ColorPiskersSliderState();
}

class _ColorPiskersSliderState extends State<ColorPiskersSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 260,
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: new Text("Slider Filter Color"),
          ),
          Divider(
            height: 1,
          ),
          SizedBox(height: 20),
          new Text("Slider Color"),
          SizedBox(height: 10),
          BarColorPicker(
              width: 300,
              thumbColor: Colors.white,
              cornerRadius: 10,
              pickMode: PickMode.Color,
              colorListener: (int value) {
                setState(() {
                  //  currentColor = Color(value);
                });
              }),
          SizedBox(height: 20),
          new Text("Slider Opicity"),
          SizedBox(height: 10),
          Slider(value: 0.1, min: 0.0, max: 1.0, onChanged: (v) {})
        ],
      ),
    );
  }
}
