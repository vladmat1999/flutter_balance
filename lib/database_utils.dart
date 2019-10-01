///A utility class used for creating, managing and querying the
///database. 

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper
{
  ///Variables describing the database
  static final _databaseVersion = 1;
  static final table = "history";

  ///Code to deal with singleton class creation
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  ///Gets a Future containing a Database object and initializes 
  ///the database if it does not exist
  static Database _database;
  Future<Database> get database async {
    if(_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  ///Initialize the database
  _initDatabase() async {
    String path = await getDatabasesPath();
    String dbpath = join(path, "database2.db");
    return await openDatabase(dbpath,
                              version: _databaseVersion,
                              onCreate: _onCreate);
  }

  ///Method to deal with database initialization. It creates
  ///the tables needed when initializing for the first time 
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE history (
      id INTEGER PRIMARY KEY,
      date STRING NOT NULL,
      amount DOUBLE NOT NULL,
      ballance DOUBLE NOT NULL,
      location STRING NOT NULL
    )
    ''');
  }

  ///Inserts an item into the database
  ///It replaces conflicting items
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  ///It gets returns all the entries in the table in a map
  Future<List<Map<String, dynamic>>> getRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  ///It returns all the entries in the table in a TableEntry structure
  ///More useful than returning a map
  Future<List<TableEntry>> getEntries() async {
    final List<Map<String, dynamic>> maps = await getRows();
    return List.generate(maps.length, (i){
      return TableEntry(
        id: maps[i]["id"],
        date: DateTime.parse(maps[i]["date"]),
        amount: maps[i]["amount"],
        ballance: maps[i]["ballance"],
        location: maps[i]["location"]
      );
    });
  }

  ///It clears all the rows from the database's tables. Used 
  ///mainly for debugging
  clear() async {
    Database db = await instance.database;
    db.rawQuery('''
      DELETE FROM history
    ''');
  }
}

///A class used to model the items in the database
class TableEntry
{
  final int id;
  final DateTime date;
  final double amount;
  final double ballance;
  final String location;

  TableEntry({this.id, this.date, this.amount, this.ballance, this.location});

  ///Unless the ID is specified, the database will autoincrement the id
  ///of the inserted item. This is why we construct an item with a null id
  Map<String, dynamic> toMap()
  {
    if(id == null)
      return
      {
        'date': date.toString(),
        'amount': amount,
        'ballance': ballance,
        'location': location
      };
    else
    {
      return
      {
        'id': id,
        'date': date.toString(),
        'amount': amount,
        'ballance': ballance,
        'location': location
      };
    }
  }
}

///Utility class used to format dates when displaying on screen.
///Might need to be moved to a separate file in the future, but for now
///it sits here with other utility functions.
class DateFormatter
{
  static String formatDate(DateTime date)
  {
    return "${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year.toString()}";
  }

  static String formatTime(DateTime date)
  {
    return "${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}:${date.second.toString().padLeft(2,'0')}";
  }
}