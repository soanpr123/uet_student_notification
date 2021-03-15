import 'package:flutter/material.dart';

class ItemListPost extends StatelessWidget {
  final int index;
  final String firstCharacter;
  final String title;
  final String subtile;
  final String createdDate;
  final bool isRead;
  ItemListPost({
    this.index,this.title,this.firstCharacter,this.subtile,this.createdDate,this.isRead
});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 55,
              height: 55,
              alignment: Alignment.centerLeft,
              child: new SizedBox(
                  child: FloatingActionButton(
                    heroTag: "$index",
                    backgroundColor: Colors.blue,
                    child: Text(
                      firstCharacter,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    onPressed: null,
                  ))),
          SizedBox(width: 22.0,),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isRead ? Colors.black : Colors.red,
                            fontSize: 17.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "$subtile...",
                          style: TextStyle(
                            color: isRead ? Colors.black54 : Colors.red,
                            fontSize: 15.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text(createdDate ?? "Undefined",style: TextStyle(
                          fontSize: 13
                      ),),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
