import 'package:flutter/material.dart';
import 'package:image_editor_pro/data/data.dart';

class Emojies extends StatefulWidget {
  @override
  _EmojiesState createState() => _EmojiesState();
}

class _EmojiesState extends State<Emojies> {
  List emojes = List();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 400,        
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.9, color: Colors.grey[400])]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Stack(
                children: [
                  Center(
                      child: Text(
                    "Selecione um Emoji",
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
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
            new SizedBox(
              height: 10,
            ),
            Container(
              height: 315,
              child: GridView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisSpacing: 0.0, maxCrossAxisExtent: 60.0),
                  children: emojis.map((String emoji) {
                    return Center(
                      child: GridTile(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, emoji);
                          setState(() {});
                        },
                        child: Container(
                          child: Text(
                            emoji,
                            style: TextStyle(fontSize: 35),
                          ),
                        ),
                      )),
                    );
                  }).toList()),
            ),
          ],
        ));
  }

  List<String> emojis = new List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emojis = getSmileys();
  }
}
