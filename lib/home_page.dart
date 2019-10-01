///The home page for the app where the data will be 
///introduced
///Consists of two keyboards which change with swipe gestures 
///and a total balance display

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

class TestPage extends State<HomePage> with SingleTickerProviderStateMixin{
  ///The instance to the database
  final dbHelper = DatabaseHelper.instance;

  ///The textAl variable keeps track of the text alignment in
  ///in display screen. When data is introducd, it will center
  ///the text.
  var textAl = Alignment.bottomCenter;

  ///The textColor is used to display the color for the balance
  var textColor = Colors.black;

  ///Text displayed in the display area
  var screenText = "0";

  ///The sign of the keyboard and the input text
  var sign = -1;
  var input = "0";

  var currentBallance = 0.0;

  ///The state variable is used to determine when the
  ///user is typing or has already entered and change the
  ///app behaviour depending on it
  var state = 0;

  ///The location at which the amount in entered
  var dropdownValue = "Unknown Location";
  
  ///Default values for the dropdown location select. More will
  ///be added from memory when the widget is build
  var allValues = <String>["Unknown Location"].toSet();

  final _formKey = GlobalKey<FormState>();

  TextEditingController newPlaceText = TextEditingController();

  ///Used to rotate the change keyboard button on the right
  double rotationAmount = -1;

  ///Initial keyboard page
  PageController controller = PageController(initialPage: 0);

  //Main Screen build

  ///Initialize the state
  @override
  void initState() {
    super.initState();

    ///Load the balance and the locations
    readBallance();
    readValues();

    ///Add a listener to rotate the change keyboard button
    controller.addListener(() {
      setState(() {
      rotationAmount = controller.page * 2 - 1;

      ///Set the sign of the keyboard when it switches
      sign = controller.page > 0.5 ? 1 : -1;
      
       if(state == 1)
       {
        ///Add a plus or minus sign when entering the amount, depending on the sign
        if(screenText[0] != (sign >= 0 ? '+' : '-'))
          screenText = (sign > 0 ? '+' : '-') + screenText.substring(1);
       }
       
      });
    });
  }

  ///Build the state
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Balance"),
        
        ///The appBar contains a button that takes you to the graph page
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

      ///The body of the widget 
      body: Container(
        child: Column(
          children: <Widget>[

            ///Separator
            Container(
              height: 20,
              color: Colors.white,
            ),

            ///This will hold the display, dropdown menu and keyboard
            Row(
              children: widgets(<Widget>[

                ///The display will fill the remainder of the screen
                Expanded(
                  ///An InkWell is used to navigate to the graph page
                  ///when the balance is tapped
                  child: InkWell(
                    ///The display area
                    child: Container(
                        height: 80,
                        alignment: textAl,
                        color: Colors.white,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          
                          ///Set and format the text
                          child: Text(
                            "$screenText",
                            style: TextStyle(color: textColor, fontSize: 200),
                            textAlign: TextAlign.right,
                          ),
                        )
                      ),

                    ///When the balance is tapped, navigate to the graph page
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

            ///This holds the dropdown menu, add location and switch keyboard buttons
            Row(
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),

                ///The dropdown menu fills the remainder of the screen
                Expanded(
                  child: Container(
                    color: Colors.white,
                    ///Add a theme to ensure the dropdown menu is white
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white,
                        backgroundColor: Colors.white,
                        primaryColor: Colors.white
                      ),

                      ///Dropdown menu
                      child: DropdownButton<String>(
                      isExpanded: true,
                      ///Set to default in initState, set to last value in
                      ///database query
                      value: dropdownValue,
                      iconEnabledColor: Colors.black,

                      ///On changed, set the current value and save it for 
                      ///a future session
                      style: TextStyle(color: Colors.black,),
                      onChanged: (String newValue){print(newValue);setState(() {
                        dropdownValue = newValue; 
                        saveValues();
                      });},

                      ///Build the items
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

                ///The "Add Location" button of the dropdown menu
                ///used for adding a new location to the list.
                ///When a location is added, it is automatically selected
                IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.black,
                  tooltip: "Add a new location",
                  onPressed: (){
                  ///OnPressed, show a new dialog to add the location
                   showDialog(
                     context: context,
                     builder: (BuildContext context){
                       return AlertDialog(
                         title: Text("Add new location"),
                         content: Form(
                           key: _formKey,
                           child: TextFormField(
                             ///Validate the location
                                  autofocus: true,
                                  validator: (value){if(value != null && value != "") return null; else return "Invalid";},
                                  controller: newPlaceText,
                                  decoration: InputDecoration(
                                                labelText: 'Location Name', hintText: 'eg. Unknown location'
                                  ),
                               ),
                           ),

                           ///A button has to be pressed to add the location
                           actions: <Widget>[
                             RaisedButton(
                                 child: Text("Add"),
                                 onPressed: (){
                                   ///Validate the location and add it to the list.
                                   ///Also save the values in memory
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
                
                ///The switch keyboard button rotates with the keyboard
                Container(
                  child: Transform.rotate(
                    ///The angle is the rotationAmount * pi / 2, since rotationAmount
                    ///goes from -1 to 1, this will give us -90 to 90 rotation range
                    angle: rotationAmount *1.57,
                    
                    ///The switch keyboard button
                    child: IconButton(
                      icon: Icon(Icons.last_page),
                      color: Colors.black,

                      ///Set the state and switch the keyboard. 
                      onPressed: (){
                        var page = sign >= 0 ? 0 : 1;
                        setState(() {
                         controller.animateToPage(page, duration: Duration(milliseconds: 500), curve: Curves.easeOutExpo); 
                        });
                      },
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

            ///Keyboard expanded to fill up the page
            Expanded(

              ///The two keyboards are put in a PageView, with swipe to
              ///change them and the sign
              child: PageView(
                physics: BouncingScrollPhysics(),
                controller: controller,
                children: <Widget>[
                  Container(
                    ///Generate the red (subtract) keyboard
                    child:  keyboard(Colors.red),
                    color: Colors.white,
                  ),

                  Container(
                    ///Generate the green (add) keyboard
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

  ///This method builds a keyboard given the color.
  ///It uses 4 rows and 3 columns of buttons.
  Widget keyboard(Color color) {
    return Column(
      children: <Widget>[
        Expanded(
          ///First row
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button("1", () => verifyButton("1"), color),
            _button("2", () => verifyButton("2"), color),
            _button("3", () => verifyButton("3"), color),
          ],
        ),
        ),

        Expanded(
          ///Second row
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button("4", () => verifyButton("4"), color),
            _button("5", () => verifyButton("5"), color),
            _button("6", () => verifyButton("6"), color),
          ],
        ),
        ),

        Expanded(
          ///Third row
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button("7", () => verifyButton("7"), color),
            _button("8", () => verifyButton("8"), color),
            _button("9", () => verifyButton("9"), color),
          ],
        ),
        ),

        Expanded(
          ///Fourth row, containing the enter button
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _button(".", () => verifyButton("."), color),
            _button("0", () => verifyButton("0"), color),
            enterButton()
          ],
        ),
        ),
        
        
      ],
    );
  }

  ///This method will return a keyboard buton based on a 
  ///function, the keyboard color and the buton string
  Widget _button(String number, Function() f, Color color) {
    ///The buttons are expanded to fll up the keyboard
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

  ///Returns a widget containing the delete button
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
        ///On a short tap, delete the last character
        onTap: () => deleteText(),
        ///On a long tap, delete the entire text
        onLongPress: () => deleteAllText(),
        splashColor: Colors.black,
      );
    else
      return null;
  }

  ///This method returns a custom enter button. On pressed, it will input
  ///the amount
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

  ///Verifies the input if it is in a valid form
  void verifyButton(String s) {
    ///If a button is pressed, the user is typing
    state = 1;

    ///Allow only one dot
    if (s == "." && hasDot()) return;

    ///Allow only one 0 instead of a string of the form "0000"
    if(s == '0' && input == "0") return;

    ///Add a 0 if the dot is pressed first
    if(s == '.' && input.length == 0)
      input += '0';

    ///Add a dot if a zero string is followed by a number
    if(s != "." && input == "0")
      input += '.';

    ///Set the state of the screen
    setState(() {
      if (input != "")
        input += s;
      else
        input = s;

      setScreen(state);
    });
  }

  ///Deletes the last element from the text
  void deleteText() {
    setState(() {
      input = input.substring(0, input.length - 1);

      ///If there is no input text, switch to balance
      if (input == "") {
        state = 0;
      }

      setScreen(state);
    });
  }

  ///Deletes all the text from the screen and switches to balance
  void deleteAllText() {
    setState(() {
      input = "";

      if (input == "") {
        state = 0;
      }

      setScreen(state);
    });
  }

  ///Updates the sign of the keyboard
  int checkSign() {
    if (controller.page == 1)
      sign = 1;
    else
      sign = -1;

    return sign;
  }

  ///When the enter butto is pressed, is will add the input to
  ///the balance
  void enterButtonPressed() {

    setState(() {
      ///Return to the balance states
      state = 0;

      ///Don't add 0
      if(input == "0")
        return;
      
      ///Parse the input
      double parsedInput = double.parse(input);

      ///Add it to the balance and save
      if(parsedInput != 0)
      {
        double amount = checkSign() * parsedInput;
        currentBallance += amount;

        saveBallance();
        _insert(amount);
      }

      setScreen(state);
      setBallanceColor();
      });
  }

  ///Sets the color of the balance according to it's value
  void setBallanceColor()
  {
      if (currentBallance > 0)
        textColor = Colors.lightGreen[900];
      else if (currentBallance < 0)
        textColor = Colors.red;
      else
        textColor = Colors.grey;
  }

  ///This will set the style of the display and text displayed depending on the state
  ///variable. When it is 1, it will display the amount entered. When it is 0, it will display
  ///the balance.
  void setScreen(int i) {
    
    ///Display the balance
    if (i == 0) {
      textAl = Alignment.bottomCenter;
      screenText = format(currentBallance);
      input = "";
      setBallanceColor();
    } 

    ///Display the amount enetered
    else 
    {
      textAl = Alignment.bottomRight;
      textColor = Colors.black;
      screenText = (sign > 0 ? "+" : '-') + input;
    }
    getDeleteButton(state);
  }

  bool hasDot() {
    return input.contains(".");
  }

  ///Used to format the balance
  String format(double n) {
    n = (n * 100).truncateToDouble() / 100.0;
    var s = n > 0 ? "+" : "";
    return s + n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  ///Helper method used to remove null widgets from a list
  List<Widget> widgets(List<Widget> wg) {
    return wg..removeWhere((widget) => widget == null);
  }

  ///Reads the balance from preferences
  readBallance() async {
    final prefs = await SharedPreferences.getInstance();
    currentBallance = prefs.getDouble("currentBallance") ?? 0;

    setState(() {
      setScreen(state); 
    });
  }

  ///Saves the balance to preferences
  saveBallance() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("currentBallance", currentBallance);
  }

  ///Saves the dropdown button values to preferences. Since it contains
  ///only a small number of strings, it is better to save it here than
  ///in a database
  saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("allValues", allValues.toList());
    prefs.setString("currentValue", dropdownValue);
  }

  ///Reads the dropdown values from preferences
  readValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      var tmp =  prefs.getStringList("allValues") ?? <String>["Unknown Location"];
      allValues = tmp.toSet();
      dropdownValue = prefs.getString("currentValue") ?? "Unknown Location";      
    });
  }

  ///Inserts into the database an entry containing the amount, balance, time and location
  ///when pressing Enter.
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
