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
  final dbHelper = DatabaseHelper.instance;
  List<ListTile> entries = <ListTile>[];
  var data = [
    GraphPoint(0,0),
  ];

  var minPoint = 0;
  var maxPoint = 10;

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    updateChart();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    minPoint = minPoint ?? 0;
    maxPoint = maxPoint ?? 10;

    var series = [
      new Series(
        id : "Clicks",
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
      body: FutureBuilder<List<TableEntry>>(
              future: dbHelper.getEntries(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                //_controller.addListener(_scrollListener());
                //_controller.addListener(_scrollListener());

                var newData = snapshot.data.reversed.toList();

                return Center(child: Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: LineChart(series, 
                      animate: true,
                      domainAxis: NumericAxisSpec(
                        viewport: NumericExtents.fromValues([minPoint, maxPoint]),
                        showAxisLine: true,
                      ),
                      behaviors: [PanAndZoomBehavior()],
                      )
                    ),

                    Expanded(
                      child: ListView.builder(
                            controller: _controller,
                            itemBuilder: (context, i) {
                    
                    if(i ~/ 2 >= newData.length)
                      return null;

                    else if(i.isOdd)
                      return Divider(color: Colors.grey,);

                    var item = newData[i ~/ 2];
                    
                    return ListTile(
                    title:Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(DateFormatter.formatDate(item.date), style: TextStyle(
                              color: Colors.black,
                              fontSize: 15
                            )),
                            Padding(padding: EdgeInsets.only(bottom: 2),),
                            Text(DateFormatter.formatTime(item.date), style: TextStyle(
                              color: Colors.black,
                              fontSize: 15
                            )),
                          ],
                        ),

                        Padding(padding: EdgeInsets.symmetric(horizontal: 4),),

                        Expanded(
                          child: Center(
                                        child: Text(item.location, style: TextStyle(
                              color: Colors.black,
                              fontSize: 15
                            ), overflow: TextOverflow.ellipsis, maxLines: 1,),
                          ),
                        ),

                        Padding(padding: EdgeInsets.symmetric(horizontal: 4),),

                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(formatAmount(item.amount), style: TextStyle(
                                              color: getAmountColor(item.amount),
                                            )
                                          ),

                              Container(
                                color: Colors.black,
                                height: 2,
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),

                              Text(item.ballance.toInt().toString(), style: TextStyle(color: Colors.grey))
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

  String formatAmount(double amount)
  {
    String text = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
    text = amount > 0 ? "+" + text : text;
    return text; 
  }

  getAmountColor(double amount)
  {
    if(amount > 0)
      return Colors.green;
    else if(amount < 0)
      return Colors.red;
    else return Colors.grey;
  }

  updateChart() async 
  {
    List<TableEntry> te = await dbHelper.getEntries();
    if(te == null || te.length == 0 )
      return;
    
    setState(() {
     maxPoint = te.length;
     minPoint = maxPoint - 10 > 0 ? maxPoint - 10 : 0;

     print("asd" + maxPoint.toString());
     print("min" + minPoint.toString());

     data = List.generate(te.length, (i){
       return GraphPoint(i,te[i].ballance);
     });
    });
  }

  _scrollListener()
  {
    print(_controller.offset);
  }
}

class GraphPoint
{
  final int x;
  final double y;

  GraphPoint(this.x, this.y);
}