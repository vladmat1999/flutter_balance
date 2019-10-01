///The graph_page builds the page presenting the
///graph and transaction breakdown

import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'package:charts_flutter/flutter.dart';

class GraphPage extends StatefulWidget
{  
  @override
  State<StatefulWidget> createState() {
    return GraphPageState();
  }
  }

class GraphPageState extends State<GraphPage>
{
  ///This will be used to access nd perform operations on the database
  final dbHelper = DatabaseHelper.instance;  

  ///This part of the code is used to control the initial zoom and pan
  ///on the graph. It plots a ingle grph point 
  List<ListTile> entries = <ListTile>[];

  ///Used to handle the minimum and maximum points when the graph has
  ///less than 10 entries
  var data = [
    GraphPoint(0,0),
  ];

  var minPoint = 0;
  var maxPoint = 10;

  ///Initialize the state by updating pulling 
  ///data from the database and updating the chart
  ///and scroll controller
  @override
  void initState() {
    super.initState();
    updateChart();
  }

  @override
  Widget build(BuildContext context) {

    //Build a new series of graph points
    var series = [
      new Series(
        id : "Balance",
        domainFn: (GraphPoint gp, _) => gp.x,
        measureFn: (GraphPoint gp, _) => gp.y,
        data: data
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),

      backgroundColor: Colors.white,

      ///The body consists of a FutureBuilder used to 
      ///wait for the data to be pulled from the db
      body: FutureBuilder<List<TableEntry>>(

              ///The builder will be based on a Future
              ///containing the db entries
              future: dbHelper.getEntries(),

              builder: (context, snapshot) {
                ///Set a loading indicator
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                ///The data comes from the daatabase from old to new, so it has
                ///to be reversed to get data from new to old
                var newData = snapshot.data.reversed.toList();

                ///The body consists of two columns containing the table and
                ///some separators
                return Center(child: Column(
                  children: <Widget>[

                    //The first object is the line graph
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: LineChart(series, 
                      animate: true,
                      ///Zoom the axis between min and max points
                      domainAxis: NumericAxisSpec(
                        viewport: NumericExtents.fromValues([minPoint, maxPoint]),
                        showAxisLine: true,
                      ),
                      //Add the pan and zoom behaviour
                      behaviors: [PanAndZoomBehavior()],
                      )
                    ),

                    ///The Expanded widget contains the list of the transsactions
                    ///and fills the rest of the screen
                    Expanded(
                      
                      ///Build the listview
                      child: ListView.builder(
                        itemBuilder: (context, i) {

                          ///Stop the builder when the list ends
                          if(i ~/ 2 >= newData.length)
                            return null;

                          ///On odd numbered add a divider
                          else if(i.isOdd)
                            return Divider(color: Colors.grey,);

                          ///Since we add data on even numbers, the 
                          ///data item will be i/2
                          var item = newData[i ~/ 2];
                          
                          ///Generate the list tile
                          ///It is sepparated into 3 rows, the first and
                          ///last each containing 2 columns and other separators
                          return ListTile(
                            title:Row(

                              ///This comlumn divides the date into date and time
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    ///Format the date
                                    Text(DateFormatter.formatDate(item.date), 
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15
                                      )
                                    ),

                                    Padding(padding: EdgeInsets.only(bottom: 2),),

                                    ///Format the time
                                    Text(DateFormatter.formatTime(item.date), style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15
                                      )
                                    ),
                                  ],
                                ),

                              Padding(padding: EdgeInsets.symmetric(horizontal: 4),),

                              ///The expanded widget will fill the center row
                              ///It holds the location
                              Expanded(
                                child: Center(
                                    child: Text(item.location, 
                                      style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15
                                    ),
                                   overflow: TextOverflow.ellipsis, maxLines: 1,
                                   ),
                                ),
                              ),

                              Padding(padding: EdgeInsets.symmetric(horizontal: 4),),

                              ///The third widget contains the balance and amount spend/earned
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    ///It also formats the amount
                                    Text(formatAmount(item.amount), 
                                      style: TextStyle(
                                        color: getAmountColor(item.amount),
                                      )
                                    ),

                                    Container(
                                      color: Colors.black,
                                      height: 2,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                    ),

                                    ///Get the balance and format it
                                    Text(item.ballance.toInt().toString(), 
                                      style: TextStyle(
                                        color: Colors.grey
                                        )
                                      )
                                  ],
                                ),

                                  padding: EdgeInsets.only(right: 10),
                              ),

                              Divider(color: Colors.black,)
                                
                          ],
                        )
                      );
                    },
                  ),
                )
              ]
            )
          );
        },
      )    
    );
  }

  ///Formats the amount spend/earned text
  String formatAmount(double amount)
  {
    String text = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
    text = amount > 0 ? "+" + text : text;
    return text; 
  }

  ///Helper function for formatAmount
  getAmountColor(double amount)
  {
    if(amount > 0)
      return Colors.green;
    else if(amount < 0)
      return Colors.red;
    else return Colors.grey;
  }

  ///Used to pull data from the database and update the chart
  updateChart() async 
  {
    //Get all the entries from the table and ensure they are not empty
    List<TableEntry> te = await dbHelper.getEntries();
    if(te == null || te.length == 0 )
      return;

    setState(() {
     //Sets the min and max point to be displayed on screen
     maxPoint = te.length;
     minPoint = maxPoint - 10 > 0 ? maxPoint - 10 : 0;

     //Generate the graph points
     data = List.generate(te.length, (i){
       return GraphPoint(i,te[i].ballance);
     });
    });
  }
}

///Data structure representing a graph point
class GraphPoint
{
  final int x;
  final double y;

  GraphPoint(this.x, this.y);
}