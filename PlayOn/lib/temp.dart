import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not Joined yet'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlineButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GettingToken()));
                },
                child: Text('Joingame'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OpponentLeft extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('opponent left'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlineButton(
                onPressed: () {},
                child: Text('Join new game'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Waiting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('waiting for opponent to join'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('joining'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return JoinGame();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Loading();
      },
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('something went wrong'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('try refreshing page'),
            ],
          ),
        ],
      ),
    );
  }
}

int rowCount = 7;
int colCount = 6;
int roomid = -1;
int playerid = -1;
List<List<int>> board = [
  [0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0]
];
int move = 0;
bool isgameover = false;
int totalplayersjoined = 0;
int winner = -1;
FirebaseFirestore users = FirebaseFirestore.instance;

class GettingToken extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: users.collection('counters').doc('0').get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return SomethingWentWrong();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          roomid = snapshot.data.data()['counter'];
          users.collection('counters').doc('0').set({'counter': roomid + 1});

          if (roomid % 2 == 0) {
            playerid = 0;
            totalplayersjoined += 1;
            users.collection('matches').doc((roomid).toString()).set({
              'board': {
                '0': [0, 0, 0, 0, 0, 0],
                '1': [0, 0, 0, 0, 0, 0],
                '2': [0, 0, 0, 0, 0, 0],
                '3': [0, 0, 0, 0, 0, 0],
                '4': [0, 0, 0, 0, 0, 0],
                '5': [0, 0, 0, 0, 0, 0],
                '6': [0, 0, 0, 0, 0, 0],
              },
              'move': 0,
              'totalplayersjoined': 1,
              'isgameover': false,
              'winner': 0
            });
          } else {
            roomid -= 1;
            playerid = 1;
            users
                .collection('matches')
                .doc((roomid).toString())
                .update({'totalplayersjoined': 2});
          }
          return GameStream();
        }

        return Loading();
      },
    );
  }
}

class GameStream extends StatelessWidget {
  final DocumentReference match =
      users.collection('matches').doc((10).toString());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: match.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        try {
          if (snapshot.hasError) {
            print(snapshot.error);
            return SomethingWentWrong();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }
          for (int i = 0; i < 7; i++)
            for (int j = 0; j < 6; j++) {
              board[i][j] = snapshot.data.data()['board'][i.toString()][j];
            }
          move = snapshot.data.data()['move'];
          totalplayersjoined = snapshot.data.data()['totalplayersjoined'];
          isgameover = snapshot.data.data()['isgameover'];
          winner = snapshot.data.data()['winner'];
          if (isgameover) {
            return Result();
          }
          if (totalplayersjoined == 1) {
            return Waiting();
          }
          return Game();
        } catch (error) {
          roomid = -1;
          playerid = -1;
          board = [
            [0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0]
          ];
          move = 0;
          isgameover = false;
          totalplayersjoined = 0;
          winner = -1;
          return OpponentLeft();
        }
      },
    );
  }
}

String result(num) {
  users.doc(roomid.toString()).delete();
  if (num == playerid) {
    roomid = -1;
    playerid = -1;
    board = [
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0]
    ];
    move = 0;
    isgameover = false;
    totalplayersjoined = 0;
    winner = -1;
    return 'You Won last game';
  } else {
    roomid = -1;
    playerid = -1;
    board = [
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0]
    ];
    move = 0;
    isgameover = false;
    totalplayersjoined = 0;
    winner = -1;
    return 'You loose last game';
  }
}

class Result extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result(winner)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlineButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GettingToken()));
                },
                child: Text('Join new game'),
              ),
            ],
          ),
        ],
      ),
    );
    ;
  }
}

class Game extends StatelessWidget {
  @override
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
                  onTap: () {},
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
                      if (board[rowNumber][columnNumber] == 0 &&
                          move == playerid) {
                        board[rowNumber][columnNumber] = playerid + 1;
                        move = (move + 1) % 2;

                        bool iswin = _handlemove(rowNumber, columnNumber,
                            board[rowNumber][columnNumber]);
                        users.doc(roomid.toString()).update({
                          'move': move,
                          'board': {
                            '0': board[0],
                            '1': board[1],
                            '2': board[2],
                            '3': board[3],
                            '4': board[4],
                            '5': board[5],
                            '6': board[6],
                          },
                          'isgameover': iswin,
                          'winner': iswin ? playerid : (playerid + 1) % 2
                        });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlineButton(
                    onPressed: () {
                      users.doc(roomid.toString()).delete();
                      roomid = -1;
                      playerid = -1;
                      board = [
                        [0, 0, 0, 0, 0, 0],
                        [0, 0, 0, 0, 0, 0],
                        [0, 0, 0, 0, 0, 0],
                        [0, 0, 0, 0, 0, 0],
                        [0, 0, 0, 0, 0, 0],
                        [0, 0, 0, 0, 0, 0],
                        [0, 0, 0, 0, 0, 0]
                      ];
                      move = 0;
                      isgameover = false;
                      totalplayersjoined = 0;
                      winner = -1;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => JoinGame()));
                    },
                    child: Text('leave game'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

bool isValid(int x, int y) {
  if (x >= 0 && x < rowCount && y >= 0 && y < colCount)
    return true;
  else
    return false;
}

bool _handlemove(int x, int y, int val) {
  for (int j = 0; j <= 3; j++) {
    int i = x - j + 3;
    int k = y + j - 3;
    if (isValid(i, k) &&
        isValid(i - 3, k + 3) &&
        board[i][k] == val &&
        board[i - 1][k + 1] == val &&
        board[i - 2][k + 2] == val &&
        board[i - 3][k + 3] == val) {
      return true;
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
      return true;
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
      return true;
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
      return true;
    }
  }
  return false;
}

Image getImage(num) {
  if (num == 0)
    return Image.asset('images/r.jpg');
  else if (num == 1)
    return Image.asset('images/o.jpg');
  else
    return Image.asset('images/x.jpg');
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectFour',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstPage(),
    );
  }
}
