import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {

  final Color? appBarColor;
  final Color? bottomColor;

  TextEditor({this.appBarColor, this.bottomColor});

  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  TextEditingController name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: widget.appBarColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(        
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(  
                    borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  labelText: "Texto",
                  hintStyle: TextStyle(
                    color: Colors.black
                  ),
                  alignLabelWithHint: true,                  
                ),              
                scrollPadding: EdgeInsets.all(20.0),
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                style: TextStyle(
                  color: Colors.black,
                ),
                autofocus: true,),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: new TextButton(
                  onPressed: () {
                    Navigator.pop(context,name.text);
                  }, 
                  style: TextButton.styleFrom(
                    backgroundColor: widget.bottomColor,
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),        
                  child: new Text("Adicionar Texto",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white
                  ),)),
              )
            ],
          ),
        ),
      )
    );
  }
}
