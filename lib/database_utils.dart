import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper
{
  static final _databaseName = "database.db";
  static final _databaseVersion = 1;
  static final table = "history";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if(_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = await getDatabasesPath();
    String dbpath = join(path, "database2.db");
    return await openDatabase(dbpath,
                              version: _databaseVersion,
                              onCreate: _onCreate);
  }

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

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<TableEntry>> getEntries() async {
    final List<Map<String, dynamic>> maps = await getRows();
    print(maps.length);
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

  clear() async {
    Database db = await instance.database;
    db.rawQuery('''
      DELETE FROM history
    ''');
  }
}

class TableEntry
{
  final int id;
  final DateTime date;
  final double amount;
  final double ballance;
  final String location;

  TableEntry({this.id, this.date, this.amount, this.ballance, this.location});

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