import 'package:flutter/material.dart';
import 'package:image_editor_pro/data/data.dart';

class Emojies extends StatefulWidget {
  @override
  _EmojiesState createState() => _EmojiesState();
}

class _EmojiesState extends State<Emojies> {
  List emojes = [];

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.9, color: Colors.grey[400]!)]),
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
              height: MediaQuery.of(context).size.height * 0.45,
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

  List<String> emojis = [];
  @override
  void initState() {
    super.initState();
    emojis = getSmileys();
  }
}
