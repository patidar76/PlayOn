import 'package:flutter/material.dart';

Image getImage(num) {
  if (num == 0)
    return Image.asset('images/r.jpg');
  else if (num == 1)
    return Image.asset('images/o.jpg');
  else
    return Image.asset('images/x.jpg');
}

class FourInARow extends StatefulWidget {
  @override
  _FourInARowState createState() => _FourInARowState();
}

class _FourInARowState extends State<FourInARow> {
  int rowCount = 7;
  int colCount = 6;
  int playerid;
  int roomid;
  int move;
  List<List<int>> board;
  @override
  void initState() {
    super.initState();
    _initialiseGame();
  }

  void _initialiseGame() {
    board = List.generate(rowCount, (i) {
      return List.generate(colCount, (j) {
        return 0;
      });
    });
    move = 0;
    setState(() {});
  }

  bool isValid(int x, int y) {
    if (x >= 0 && x < rowCount && y >= 0 && y < colCount)
      return true;
    else
      return false;
  }

  void _handlemove(int x, int y, int val) {
    for (int j = 0; j <= 3; j++) {
      int i = x - j + 3;
      int k = y + j - 3;
      if (isValid(i, k) &&
          isValid(i - 3, k + 3) &&
          board[i][k] == val &&
          board[i - 1][k + 1] == val &&
          board[i - 2][k + 2] == val &&
          board[i - 3][k + 3] == val) {
        _handleWin();
        return;
      }
    }
    for (int j = 0; j <= 3; j++) {
      int i = x - j + 3;
      int k = y - j + 3;
      if (isValid(i, k) &&
          isValid(i - 3, k - 3) &&
          board[i][k] == val &&
          board[i - 1][k - 1] == val &&
          board[i - 2][k - 2] == val &&
          board[i - 3][k - 3] == val) {
        _handleWin();
        return;
      }
    }
    for (int j = 0; j <= 3; j++) {
      int i = x - j + 3;
      int k = y;
      if (isValid(i, k) &&
          isValid(i - 3, k) &&
          board[i][k] == val &&
          board[i - 1][k] == val &&
          board[i - 2][k] == val &&
          board[i - 3][k] == val) {
        _handleWin();
        return;
      }
    }
    for (int j = 0; j <= 3; j++) {
      int i = x;
      int k = y - j + 3;
      if (isValid(i, k) &&
          isValid(i, k - 3) &&
          board[i][k] == val &&
          board[i][k - 1] == val &&
          board[i][k - 2] == val &&
          board[i][k - 3] == val) {
        _handleWin();
        return;
      }
    }
  }

  void _handleWin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text("You Win!"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _initialiseGame();
                Navigator.pop(context);
              },
              child: Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Four In A Row",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF192A56),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 60.0,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _initialiseGame();
                  },
                  child: CircleAvatar(
                    child: Icon(
                      Icons.tag_faces,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    backgroundColor: Colors.yellowAccent,
                  ),
                )
              ],
            ),
          ),
          // The grid of squares
          Column(
            children: <Widget>[
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: colCount,
                ),
                itemBuilder: (context, position) {
                  // Get row and column number of square
                  int rowNumber = (position / colCount).floor();
                  int columnNumber = (position % colCount);

                  return InkWell(
                    // Opens square
                    onTap: () {
                      if (board[rowNumber][columnNumber] == 0) {
                        setState(() {
                          board[rowNumber][columnNumber] = (move % 2) + 1;
                          move += 1;
                        });

                        _handlemove(rowNumber, columnNumber,
                            board[rowNumber][columnNumber]);
                      }
                    },
                    // Flags square
                    splashColor: Colors.black,
                    child: Container(
                      child: getImage(board[rowNumber][columnNumber]),
                    ),
                  );
                },
                itemCount: rowCount * colCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
