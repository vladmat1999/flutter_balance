import 'package:flutter/material.dart';
import 'graph_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_utils.dart';

class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return TestPage();
  }
}

Widget _button(String number, Function() f, Color color) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.all(1),
      child: RaisedButton(
        child: Text(
          number,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
        ),
        textColor: Colors.white,
        color: color,
        onPressed: f,
      ))

  ,);
}

class TestPage extends State<HomePage> with SingleTickerProviderStateMixin{
  //Variables
  final dbHelper = DatabaseHelper.instance;

  var textAl = Alignment.bottomCenter;
  var textColor = Colors.black;
  var screenText = "0";
  var sign = 1;
  var input = "0";
  var currentBallance = 0.0;
  var state = 0;
  var dropdownValue = "Unknown Location";
  var allValues = <String>["Unknown Location","a"].toSet();
  final _formKey = GlobalKey<FormState>();
  TextEditingController newPlaceText = TextEditingController();
  double rotationAmount = -1;

  PageController controller = PageController(initialPage: 0);

  //Main Screen build

  @override
  void initState() {
    super.initState();
    readBallance();
    readValues();
    controller.addListener(() {
      setState(() {
       rotationAmount = controller.page * 2 - 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ballance"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
               Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GraphPage()),
                    );
            },
          )
        ],

      ),
      backgroundColor: Colors.white,

      //Display

      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
              color: Colors.white,
            ),
            Row(
              children: widgets(<Widget>[
                Expanded(
                    child: InkWell(
                  child: Container(
                      height: 80,
                      alignment: textAl,
                      color: Colors.white,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          "$screenText",
                          style: TextStyle(color: textColor, fontSize: 200),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GraphPage()),
                    );
                  },
                  splashColor: Colors.black,
                  )
                ),
                getDeleteButton(state)
              ]),
            ),

            Divider(
              color: Colors.black,
              height: 10,
            ),

            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white,
                        backgroundColor: Colors.white,
                        primaryColor: Colors.white
                      ),
                      child: DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValue,
                      iconEnabledColor: Colors.black,

                      style: TextStyle(color: Colors.black,),
                      onChanged: (String newValue){print(newValue);setState(() {
                        dropdownValue = newValue; 
                        saveValues();
                      });},
                      items: allValues.map<DropdownMenuItem<String>>((String value){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black),),
                        );
                      }).toList(),
                    ),
                    )
                    
                  )
                ),

                IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.black,
                  tooltip: "Add a new location",
                  onPressed: (){
                   showDialog(
                     context: context,
                     builder: (BuildContext context){
                       return AlertDialog(
                         title: Text("Add new location"),
                         content: Form(
                           key: _formKey,
                           child: TextFormField(
                                  autofocus: true,
                                  validator: (value){if(value != null && value != "") return null; else return "Invalid";},
                                  controller: newPlaceText,
                                  decoration: InputDecoration(
                                                labelText: 'Location Name', hintText: 'eg. Unknown location'
                                  ),
                               ),
                           ),

                           actions: <Widget>[
                             RaisedButton(
                                 child: Text("Add"),
                                 onPressed: (){
                                   if(_formKey.currentState.validate())
                                    {
                                      setState(() {
                                       allValues.add(newPlaceText.text);
                                       dropdownValue = newPlaceText.text; 
                                       newPlaceText.clear();
                                      });
                                    }
                                    saveValues();
                                    Navigator.pop(context);
                                   },
                               )
                           ],
                         );
                     }
                   );
                  },
                ),
                
                Container(
                  child: RotationTransition(
                    turns: new AlwaysStoppedAnimation(rotationAmount / 4),
                    child: Icon(
                      Icons.last_page,
                      color: Colors.black,
                    )
                  ),
                  padding: EdgeInsets.only(right: 5),
                )
              ],
            ),
            
            Divider(
              color: Colors.black,
              height: 10,
            ),        

            //Keyboard

            Expanded(
              child: PageView(
                physics: BouncingScrollPhysics(),
                controller: controller,
                children: <Widget>[
                  Container(
                    child:  keyboard(Colors.red),
                    color: Colors.white,
                  ),

                  Container(
                    child:  keyboard(Colors.green),
                    color: Colors.white,
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

//Build keyboard method

  Widget keyboard(Color color) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button("1", () => setAns("1"), color),
            _button("2", () => setAns("2"), color),
            _button("3", () => setAns("3"), color),
          ],
        ),
        ),

        Expanded(
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button("4", () => setAns("4"), color),
            _button("5", () => setAns("5"), color),
            _button("6", () => setAns("6"), color),
          ],
        ),
        ),

        Expanded(
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button("7", () => setAns("7"), color),
            _button("8", () => setAns("8"), color),
            _button("9", () => setAns("9"), color),
          ],
        ),
        ),

        Expanded(
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button(".", () => setAns("."), color),
            _button("0", () => setAns("0"), color),
            enterButton()
          ],
        ),
        ),
        
        
      ],
    );
  }

  void setAns(String s) {
    state = 1;

    if (s == "." && hasDot()) return;

    if(s == '0' && input == "0") return;

    if(s == '.' && input.length == 0)
      input += '0';

    setState(() {
      if (input != "")
        input += s;
      else
        input = s;

      setScreen(state);
    });
  }

  void deleteText() {
    setState(() {
      input = input.substring(0, input.length - 1);

      if (input == "") {
        state = 0;
      }

      setScreen(state);
    });
  }

  Widget getDeleteButton(int s) {
    if (s != 0)
      return InkWell(
        child: Container(
          height: 80,
          width: 80,
          child: Icon(
            Icons.backspace,
            color: Colors.black,
          ),
          color: Colors.white,
        ),
        onTap: () => deleteText(),
        onLongPress: () => deleteAllText(),
        splashColor: Colors.black,
      );
    else
      return null;
  }

  void deleteAllText() {
    setState(() {
      input = "";

      if (input == "") {
        state = 0;
      }

      setScreen(state);
    });
  }

  List<Widget> widgets(List<Widget> wg) {
    return wg..removeWhere((widget) => widget == null);
  }

  int checkSign() {
    if (controller.page == 1)
      sign = 1;
    else
      sign = -1;

    return sign;
  }

  Widget enterButton() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(1),
        child: RaisedButton(
          child: Text(
            "Enter",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          textColor: Colors.white,
          color: Colors.white,
          onPressed: enterButtonPressed,
        )),
    ) ;
    
  }

  void enterButtonPressed() {
    //if (input == ".") return;

    setState(() {
      state = 0;

      if(input == "0")
        return;
      double text = double.parse(input);
      print(text);
      if(text != 0)
      {
        double amount = checkSign() * text;
        currentBallance += amount;
        setScreen(state);
        setBallanceColor();

        saveBallance();
        _insert(amount);
      }
    });
        setScreen(state);
        setBallanceColor();
  }

  String format(double n) {
    n = (n * 100).truncateToDouble() / 100.0;
    var s = n > 0 ? "+" : "";
    return s + n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  void setBallanceColor()
  {
    
      if (currentBallance > 0)
        textColor = Colors.lightGreen[900];
      else if (currentBallance < 0)
        textColor = Colors.red;
      else
        textColor = Colors.grey;
  }

  void setScreen(int i) {
    if (i == 0) {
      textAl = Alignment.bottomCenter;
      screenText = format(currentBallance);
      input = "";
      setBallanceColor();
    } else 
    {
      textAl = Alignment.bottomRight;
      screenText = input;
      textColor = Colors.black;
    }
    getDeleteButton(state);
  }

  bool hasDot() {
    return input.contains(".");
  }

  readBallance() async {
    final prefs = await SharedPreferences.getInstance();
    currentBallance = prefs.getDouble("currentBallance") ?? 0;
    print(currentBallance);

    setState(() {
      setScreen(state); 
    });
  }

  saveBallance() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("currentBallance", currentBallance);
  }

  saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("allValues", allValues.toList());
    prefs.setString("currentValue", dropdownValue);
  }

  readValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      var tmp =  prefs.getStringList("allValues") ?? <String>["Unknown Location"];
      allValues = tmp.toSet();
      dropdownValue = prefs.getString("currentValue") ?? "Unknown Location";      
    });
  }

  _insert(double amount) async {
    TableEntry te = TableEntry(
      id : null,
      date: DateTime.now(),
      amount: amount,
      ballance: currentBallance,
      location: dropdownValue
    );

    dbHelper.insert(te.toMap());
  }
}
