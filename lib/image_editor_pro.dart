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
List multiwidget = [];
Color currentcolors = Colors.white;
var opicity = 0.0;
SignatureController _controller =
    SignatureController(penStrokeWidth: 3, penColor: Color(0xffB22222));
ScrollController _controllerSize;

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;
  final File defaultImage;
  final Directory pathSave;
  final String nameSave;

  ImageEditorPro({this.appBarColor, this.bottomBarColor, this.defaultImage, this.pathSave, this.nameSave,});

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
  // create some values
  Color pickerColor = Color(0xffB22222);
  Color currentColor = Color(0xffB22222);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    var points = _controller.points;
    _controller =
        SignatureController(penStrokeWidth: 3, penColor: color, points: points);
  }

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
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
  }

  getSizeAndPosition() {
    final imagemContext = _sizeImage.currentContext;
    if (imagemContext != null) {
      final Size sizeImagem = MediaQuery.of(_sizeImage.currentContext).size;

      width = sizeImagem.width;
      height = sizeImagem.height;

      print("tamanho utilizado: ${sizeImagem.toString()}");
    }
  }

  var _colorSig = Colors.orangeAccent.withOpacity(0.3);
  var _changeColor = false;

  @override
  Widget build(BuildContext context) {    

    return Scaffold(
        backgroundColor: Colors.grey,
        key: scaf,
        appBar: new AppBar(
          actions: <Widget>[
            new TextButton(
                child: new Text("Salvar", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  _imageFile = null;
                  screenshotController
                      .capture(
                          delay: Duration(milliseconds: 500), pixelRatio: 1.5)
                      .then((binaryIntList) async {                    

                    final paths = widget.pathSave ?? await getTemporaryDirectory();
                    final name = widget.nameSave ?? DateTime.now().millisecondsSinceEpoch.toString();
                    
                    print("local salvo: ${paths.path}");

                    final file = await File('${paths.path}/' + name.toString() + '.jpg').create();
                    file.writeAsBytesSync(binaryIntList);

                    Navigator.pop(context, file);
                  }).catchError((onError) {
                    print(onError);
                  });
                }),
          ],
          backgroundColor: widget.appBarColor,
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Screenshot(
                controller: screenshotController,
                child: Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: <Widget>[
                    widget.defaultImage != null
                    ? Image.file(
                        widget.defaultImage,
                        //fit: BoxFit.cover,
                      )
                    : Image.asset("assets/capa25463.jpeg")
                    ,Positioned.fill(
                      child: RepaintBoundary(
                        key: globalKey,
                        child: Center(
                            child: GestureDetector(
                                onPanUpdate: (DragUpdateDetails details) {
                                  setState(() {
                                    RenderBox object = context.findRenderObject();
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
                                    backgroundColor: Colors.transparent,// _colorSig
                                  )
                                )
                              ),
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
                                    scaf.currentState.showBottomSheet((context) {                                      
                                      return Sliders(
                                        size: f.key,
                                        sizevalue: fontsize[f.key].toDouble(),
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
                                            sizevalue: fontsize[f.key].toDouble(),
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
                          Icon(FontAwesomeIcons.brush, color: Colors.white,),
                          Text('Pintar', style: TextStyle(color: Colors.white),)
                        ],
                      ),
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Selecione uma cor'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: changeColor,
                                  showLabel: false,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Ok'),
                                  onPressed: () {
                                    setState(() => currentColor = pickerColor);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                      },
                    ),
                    TextButton(                      
                      child: Column(
                        children: [
                          Icon(Icons.text_fields, color: Colors.white,),
                          Text('Texto', style: TextStyle(color: Colors.white),)
                        ],
                      ),
                      onPressed: () async {
                        final value = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextEditor()));
                        if (value.toString().isEmpty || value == null ) {
                          print("true");
                        } else {
                          type.add(2);
                          fontsize.add(30);
                          fontColor.add(Colors.black);
                          offsets.add(Offset.zero);
                          multiwidget.add(value);
                          howmuchwidgetis++;
                        }
                        setState(() {});
                      },
                    ),
                    TextButton(                      
                      child: Column(
                        children: [
                          Icon(FontAwesomeIcons.smile, color: Colors.white,),
                          Text('Emoji', style: TextStyle(color: Colors.white),)
                        ],
                      ),
                      onPressed: (){
                        Future getemojis = showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Emojies();
                          });
                        getemojis.then((value) {
                          if (value != null) {
                            type.add(1);
                            fontsize.add(40);
                            offsets.add(Offset.zero);
                            multiwidget.add(value);
                            howmuchwidgetis++;
                            setState(() {});
                          }
                        });
                      },
                    ),
                    TextButton(                      
                      child: Column(
                        children: [
                          Icon(FontAwesomeIcons.eraser, color: Colors.white,),
                          Text('Apagar', style: TextStyle(color: Colors.white),)
                        ],
                      ),
                      onPressed: (){
                        _controller.clear();
                        type.clear();
                        fontsize.clear();
                        offsets.clear();
                        multiwidget.clear();
                        howmuchwidgetis = 0;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              )            );
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
                                    var image = await picker.getImage(source: ImageSource.camera);
                                    var decodedImage = await decodeImageFromList(File(image.path).readAsBytesSync());

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
                                  var image = await picker.getImage(source: ImageSource.gallery);
                                  var decodedImage = await decodeImageFromList(File(image.path).readAsBytesSync());                                  

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
    _controller.addListener(() => print("Value changed"));
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

  const Sliders({Key key, this.size, this.sizevalue}) : super(key: key);

  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  @override
  void initState() {
    slider = widget.sizevalue;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 180,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Stack(
                children: [
                  Center(child: Text("Tamanho e Cor", style: TextStyle(fontSize: 18),)),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        size:25,
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
                        size:25,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
            SizedBox(height: 20),
            BarColorPicker(
              width: MediaQuery.of(context).size.width * 0.90,
              thumbColor: Colors.white,
              cornerRadius: 10,
              pickMode: PickMode.Color,
              initialColor: Colors.black,
              colorListener: (int value) {
                setState(() {
                  fontColor[widget.size] = Color(value);
                });
              }
            ),
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
                    print(v.toInt());
                    fontsize[widget.size] = v.toInt();
                  });
                }),
          ],
        ));
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
             Slider(value: 0.1, 
             min: 0.0,
             max: 1.0,
             onChanged: (v)
             {

             })
        ],
      ),
    );
  }
}