import 'package:possystem/services/migrations/v1.dart' as migration_v1;
import 'package:sqflite/sqflite.dart' hide Database;
import 'package:sqflite/sqflite.dart' as no_sql show Database;

enum Tables {
  search_history,
  // order
  order,
  order_stash,
}

const Map<Tables, String> TableName = {
  Tables.search_history: 'search_history',
  // order
  Tables.order: 'order',
  Tables.order_stash: 'order_stash',
};

class Database {
  static final Database _instance = Database._constructor();

  static Database get instance => _instance;

  // delimiter: https://stackoverflow.com/a/29811033/12089368
  static final String delimiter = String.fromCharCode(13);

  static String join(Iterable<String>? data) =>
      (data?.join(delimiter) ?? '') + delimiter;

  static List<String> split(String? value) =>
      value?.trim().split(delimiter) ?? [];

  late no_sql.Database db;

  Database._constructor();

  Future<void> initialize() async {
    final databasePath = await getDatabasesPath() + '/pos_system.sqlite';
    db = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return Future.wait(migration_v1.up.map((sql) => db.execute(sql)));
      },
    );
  }

  Future<int> push(Tables table, Map<String, Object?> data) {
    return db.insert(TableName[table]!, data);
  }

  Future<int> update(
    Tables table,
    Object? key,
    Map<String, Object?> data, {
    keyName = 'id',
  }) {
    return db.update(
      TableName[table]!,
      data,
      where: '$keyName = ?',
      whereArgs: [key],
    );
  }

  Future<Map<String, Object?>?> getLast(
    Tables table, {
    String sortBy = 'id',
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final data = await db.query(
        TableName[table]!,
        columns: columns,
        orderBy: '$sortBy DESC',
        limit: 1,
        where: where,
        whereArgs: whereArgs,
      );
      return data.first;
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(
    Tables table,
    Object? id, {
    String keyName = 'id',
  }) {
    return db.delete(TableName[table]!, where: '$keyName = ?', whereArgs: [id]);
  }

  Future<int?> count(
    Tables table, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    final result = await db.query(TableName[table]!, columns: ['COUNT(*)']);

    return Sqflite.firstIntValue(result);
  }

  static Future<List<Map<String, Object?>>> query(
    Tables table, {
    String? where,
    List<Object>? whereArgs,
    bool? distinct,
    List<String>? columns,
    String? groupBy,
    String? orderBy,
    String? having,
    int? limit,
    int? offset,
  }) {
    return instance.db.query(
      TableName[table]!,
      where: where,
      whereArgs: whereArgs,
      distinct: distinct,
      columns: columns,
      groupBy: groupBy,
      orderBy: orderBy,
      having: having,
      limit: limit,
      offset: offset,
    );
  }

  static Future<List<Map<String, Object?>>> rawQuery(
    Tables table, {
    String? where,
    List<Object>? whereArgs,
    required List<String> columns,
    String? groupBy,
  }) {
    final select = columns.join(',');
    return instance.db.rawQuery('''
    SELECT $select FROM "${TableName[table]}"
    WHERE $where
    GROUP BY $groupBy''', whereArgs);
  }
}
