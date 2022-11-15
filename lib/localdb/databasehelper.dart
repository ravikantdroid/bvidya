// import 'dart:io';
import 'dart:convert';
import 'dart:io';

import 'package:evidya/model/GroupListModal.dart';
import 'package:evidya/model/recentchatconnectionslist_modal.dart';
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/delete_user_model.dart';
import '../network/repository/api_repository.dart';

class DatabaseHelper {
  static const _databaseName = "chat.db";
  static const _databaseVersion = 1;
  static const table = 'Chat';
  static const grouptable = 'groupChat';
  static const recentlist = 'recentlist';
  static const recentgrouplist = 'recentgrouplist';
  static const calllist = 'calllist';
  static const deliveryStatus = 'deliveryStatus';
  static const textId = 'textid';
  static const Id = 'id';
  static const message = 'message';
  static const reply = 'reply';
  static const timestamp = 'timestamp';
  static const diraction = 'diraction';
  static const replyText = 'reply_text';
  static const url = 'url';
  static const from = 'from_id';
  static const to = 'to_id';
  static const type = 'type';
  static const deleted = 'deleted';
  static const badge = 'badge';
  static const profile_image = 'profile_image';
  static const email = 'email';
  static const phone = 'phone';
  static const groupname = 'groupname';

  ///CallList
  static const calleeName = 'calleeName';
  static const Calldrm = 'Calldrm';
  static const calltype = 'calltype';
  static const Callid = 'callid';

  ///Recent list
  static const userid = 'userid';
  static const name = 'NAME';
  static const peerid = 'peerid';
  static const status = 'STATUS';
  static const blockstatus = 'BLOCKSTATUS';
  static const transitallowed = 'transitallowed';

  static const groupadmin = 'groupadmin';
  static const description = 'description';
  static const image = 'image';
  static const members = 'members';
  static const self = 'self';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();

    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    /*Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);*/
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      readOnly: false,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $message TEXT NOT NULL,
            $url TEXT,
            $timestamp TEXT NOT NULL,
            $diraction TEXT NOT NULL,
            $from TEXT NOT NULL,
            $to TEXT NOT NULL,
            $reply TEXT NOT NULL,
            $replyText TEXT NOT NULL,
            $type TEXT NOT NULL,
            $deliveryStatus TEXT NOT NULL,
            $textId TEXT NOT NULL,
            $deleted INTEGER DEFAULT 0
          );
          ''');
    await db.execute('''
          CREATE TABLE $grouptable (
            $Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $message TEXT NOT NULL,
            $url TEXT,
            $timestamp TEXT NOT NULL,
            $diraction TEXT NOT NULL,
            $from TEXT NOT NULL,
            $to TEXT NOT NULL,
            $reply TEXT NOT NULL,
            $replyText TEXT NOT NULL,
            $type TEXT NOT NULL,
            $textId TEXT NOT NULL,
            $groupname TEXT NOT NULL,
            $deleted INTEGER DEFAULT 0
          );
          ''');
    await db.execute('''
   create table $recentlist(
    $Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    $userid TEXT NOT NULL,
    $name TEXT NOT NULL,
    $peerid TEXT NOT NULL,
    $status TEXT NOT NULL,
    $blockstatus TEXT NOT NULL,
    $profile_image TEXT NOT NULL,
    $email TEXT NOT NULL,
    $phone TEXT NOT NULL,
    $transitallowed TEXT NOT NULL,
    $timestamp DATETIME DEFAULT 0,
    $badge VARCHAR(10) DEFAULT '0'
   );''');

    await db.execute('''
      create table $recentgrouplist(
    $Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    $groupname TEXT NOT NULL,
    $image TEXT NOT NULL,
    $groupadmin TEXT NOT NULL,
    $description TEXT NOT NULL,
    $members TEXT NOT NULL,
    $self TEXT NOT NULL,
    $badge VARCHAR(10) DEFAULT '0'
   );''');

    await db.execute('''
   create table $calllist(
    $Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    $calleeName TEXT NOT NULL,
    $calltype TEXT NOT NULL,
    $Calldrm TEXT NOT NULL,
    $Callid Text NOT NULL,
    $timestamp INTEGER DEFAULT 0
   );''');
  }

  // Helper methods 78gx422b
  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    dynamic alreadyExist = await is_message_exists(row[textId]);
    if (alreadyExist == 1) {
      // debugPrint('already exists!! skipping insert');
      return -1;
    }
    return await db.insert(table, row);
  }

  Future<int> groupinsert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    dynamic alreadyExist = await isTextIdPresentInGroup(row[textId]);
    if (alreadyExist == 1) {
      // debugPrint('already exists!! skipping insert');
      return -1;
    }
    return await db.insert(grouptable, row);
  }

  Future<int> callinsert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(calllist, row);
  }

  Future<int> recentchatlist(row) async {
    Database db = await instance.database;
    return await db.insert(recentlist, row);
  }

  Future<int> updateRecentChatList(row, peerIdValue) async {
    Database db = await instance.database;
    return await db.update(recentlist, row, where: '$peerid = $peerIdValue');
  }

  Future<int> updateRecentGroupChatList(row, name) async {
    Database db = await instance.database;
    return await db.update(recentgrouplist, row, where: "$groupname = '$name'");
  }

  Future<int> getcount(userpeerid) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) AS peer_id FROM $recentlist WHERE $peerid = $userpeerid"));
    return count;
  }

  Future<int> getGroupCount(name) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) AS groupname FROM $recentgrouplist WHERE $groupname = '$name'"));
    return count;
  }

  Future<int> updatedfcm(
    userpeerid,
    fcmtoken,
  ) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) AS fcm_token FROM $recentlist WHERE $status = '$fcmtoken' AND $peerid = $userpeerid"));
    return count;
  }

  Future<int> updatedstatus(
    userpeerid,
    status,
  ) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) AS fcm_token FROM $recentlist WHERE $blockstatus = '$status' AND $peerid = $userpeerid"));
    return count;
  }

  Future<int> is_message_exists(textid) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient
        .rawQuery("SELECT COUNT(*) FROM $table WHERE $textId = '$textid'"));
    return count;
  }

  Future<int> getExistId(textid) async {
    var dbclient = await instance.database;
    int id = Sqflite.firstIntValue(await dbclient
        .rawQuery("SELECT id FROM $table WHERE $textId = '$textid'"));
    return id;
  }

  Future<int> getGroupExistId(textid) async {
    var dbclient = await instance.database;
    int id = Sqflite.firstIntValue(await dbclient
        .rawQuery("SELECT id FROM $grouptable WHERE $textId = '$textid'"));
    return id;
  }

  Future<int> isTextIdPresentInGroup(textid) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) FROM $grouptable WHERE $textId = '$textid'"));
    return count;
  }

  Future<int> updated_transit_allowed(
    userpeerid,
    transit,
  ) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) AS fcm_token FROM $recentlist WHERE $transitallowed = '$transit' AND $peerid = $userpeerid"));
    return count;
  }

  Future<void> updatedeliverystatus(
    // msg,
    id,
    status,
  ) async {
    final db = await instance.database;
    dynamic res = await db.rawQuery(
        "UPDATE $table SET $deliveryStatus = '$status' WHERE id = $id ");
    //debugPrint(res);
  }

  Future<int> updatefcm(userpeerid, userfcmtoken) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET   $status = "$userfcmtoken"   WHERE peerid = $userpeerid');
  }

  Future<int> updatestatus(userpeerid, status) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET   $blockstatus = "$status"   WHERE peerid = $userpeerid');
  }

  Future<int> update_transit_allowed(userpeerid, transit_allowed) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET   $transitallowed = "$transit_allowed"   WHERE peerid = $userpeerid');
  }

  Future<int> updatechattable(userpeerid, userfcmtoken) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET   $status = "$userfcmtoken"   WHERE peerid = $userpeerid');
  }

  Future<int> update(pid, datetime) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET  $badge= CAST(CAST($badge AS int)+1 AS varchar), $timestamp = "$datetime"   WHERE peerid = $pid');
  }

  Future<int> sendUpdate(pid, datetime) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET  $badge= CAST(CAST($badge AS int)+0 AS varchar), $timestamp = "$datetime"   WHERE peerid = $pid');
  }

  Future<int> deletebadge(pid) async {
    final db = await instance.database;
    final res = await db
        .rawQuery("UPDATE $recentlist  SET  $badge='0' WHERE peerid = $pid");
  }

  Future<int> insertRecentChatGroupList(row) async {
    Database db = await instance.database;
    return await db.insert(recentgrouplist, row);
  }

  /// recent group list
  Future<List<Groups>> getAllgroupdata() async {
    final db = await instance.database;
    List<Map> list = await db.rawQuery("SELECT * FROM $recentgrouplist ");
    List<Groups> groups = [];
    for (var row in list) {
      final list = jsonDecode(row["members"]) as List;
      List<Members> members =
          list.map((tagJson) => Members.fromJson(jsonDecode(tagJson))).toList();
      groups.add(
        Groups(
          id: row['userid'],
          groupName: row["groupname"],
          image: row["image"],
          description: row["description"],
          groupAdmin: row["groupadmin"],
          members: members,
          self: Self.fromJson(jsonDecode(row["self"])),
        ),
      );
    }
    return groups;
  }

  // Future<int> recentchatgrouplist(row) async {
  //   Database db = await instance.database;
  //   return await db.insert(recentgrouplist, row);
  // }

  Future<int> getgroupcount(userpeerid) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) AS peer_id FROM $recentlist WHERE $peerid = $userpeerid"));
    return count;
  }

  Future<int> updatedgroupfcm(
    userpeerid,
    fcmtoken,
  ) async {
    var dbclient = await instance.database;
    int count = Sqflite.firstIntValue(await dbclient.rawQuery(
        "SELECT COUNT(*) AS fcm_token FROM $recentlist WHERE $status = '$fcmtoken' AND $peerid = $userpeerid"));
    return count;
  }

  Future<int> updategroupfcm(userpeerid, userfcmtoken) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET   $status = "$userfcmtoken"   WHERE peerid = $userpeerid');
  }

  Future<int> updaterecentgroup(pid, datetime) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET  $badge= CAST(CAST($badge AS int)+1 AS varchar), $timestamp = "$datetime"   WHERE peerid = $pid');
  }

  Future<int> sendUpdategrouplist(pid, datetime) async {
    final db = await instance.database;
    await db.rawQuery(
        'UPDATE $recentlist  SET  $badge= CAST(CAST($badge AS int)+0 AS varchar), $timestamp = "$datetime"   WHERE peerid = $pid');
  }

  Future<int> deletegroupbadge(pid) async {
    final db = await instance.database;
    final res = await db
        .rawQuery("UPDATE $recentlist  SET  $badge='0' WHERE peerid = $pid");
  }

  Future<int> deleteAllEmployees() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS recentlist");
    //final res = await db.rawQuery('TRUNCATE TABLE recentlist');
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> callListRows() async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM $calllist ORDER BY timestamp DESC");
  }

  Future<List<Map<String, dynamic>>> Alldata() async {
    Database db = await instance.database;
    return await db
        .rawQuery("SELECT * FROM $grouptable ORDER BY timestamp DESC");
  }

  Future<Connections> getUserData(String id) async {
    final db = await instance.database;
    List<Map> list =
        await db.rawQuery("SELECT * FROM $recentlist WHERE userid='$id'");
    Connections user;
    if (list.isNotEmpty) {
      for (var row in list) {
        user = Connections(
            id: row['userid'],
            badge: row["badge"],
            peerId: row["peerid"],
            name: row["NAME"],
            fcm_token: row["STATUS"],
            timeStamp: row["timestamp"],
            email: row["email"],
            phone: row["phone"],
            profile_image: row["profile_image"],
            status: row["BLOCKSTATUS"]);
      }
    }
    return user;
  }

  Future<List<Connections>> getAlldata() async {
    final db = await instance.database;
    List<Map> list =
        await db.rawQuery("SELECT * FROM $recentlist ORDER BY timestamp DESC");
    List<Connections> users = [];
    for (var row in list) {
      users.add(Connections(
          id: row['userid'],
          badge: row["badge"],
          peerId: row["peerid"],
          name: row["NAME"],
          fcm_token: row["STATUS"],
          timeStamp: row["timestamp"],
          email: row["email"],
          phone: row["phone"],
          profile_image: row["profile_image"],
          status: row["BLOCKSTATUS"]));
      // debugPrint(row.toString());
    }
    // for (int i = 0; i < list.length; i++) {
    //   users.add(Connections(
    //       id: list[i]['userid'],
    //       badge: list[i]["badge"],
    //       peerId: list[i]["peerid"],
    //       name: list[i]["NAME"],
    //       fcm_token: list[i]["STATUS"],
    //       timeStamp: list[i]["timestamp"],
    //       email: list[i]["email"],
    //       phone: list[i]["phone"],
    //       profile_image: list[i]["profile_image"],
    //       status: list[i]["BLOCKSTATUS"]));
    // }
    // debugPrint(users.toString());
    return users;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<List<Map<String, dynamic>>> queryRowCount(
      String peerid, String userpeerid) async {
    Database db = await instance.database;
    return await db.rawQuery(
        'SELECT * FROM $table WHERE ($to = $peerid AND $from = $userpeerid) OR ($to = $userpeerid AND $from = $peerid) AND $deleted = 0');
  }

  Future<List<Map<String, dynamic>>> groupqueryRowCount(
      String peerid, String userpeerid, groupnam) async {
    Database db = await instance.database;
    return await db.rawQuery(
        'SELECT * FROM $grouptable WHERE $groupname = "$groupnam" AND $deleted = 0');
  }

//TODO manage delete later
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$Id = ?', whereArgs: [id]);
  }

  Future<dynamic> deletemsg(int msgid) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$Id = ?', whereArgs: [msgid]);
  }

  Future<List<Map<String, dynamic>>> clearchat(
      String peerid, String userpeerid) async {
    Database db = await instance.database;
    return await db.rawQuery(
        'DELETE FROM $table WHERE ($to = $peerid AND $from = $userpeerid) OR ($to = $userpeerid AND $from = $peerid)');
  }

  Future<List<Map<String, dynamic>>> cleargroupchat(
    String selectedgroupname,
  ) async {
    Database db = await instance.database;
    return await db.rawQuery(
        'DELETE FROM $grouptable WHERE ($groupname = "$selectedgroupname")');
  }

  Future<List<Map<String, dynamic>>> deletechatlist() async {
    Database db = await instance.database;
    return await db.rawQuery('DELETE FROM $recentlist WHERE 1');
  }

  Future<bool> loadAndResetDB(String token) async {
    try {
      String path = join(await getDatabasesPath(), 'chat_copy.db');
      final result = await ApiRepository().loadDB(token);
      if (result != null &&
          result.status == 'successfull' &&
          result.body?.backupUrl?.isNotEmpty == true) {
        // print('downloading backup file at @$path');
        await ApiRepository().downloadFile(result.body.backupUrl, path);

        File file = File(path);

        if (await file.exists()) {
          // print('download backup file at @$path');

          String oldPath = join(await getDatabasesPath(), _databaseName);
          File oldFile = File(oldPath);

          if (await oldFile.exists()) {
            _database.close();
            // print('old database file not exist');
            await oldFile.delete();
          }
          await file.copy(oldPath);
          // print('new database file copied to ');

          _database = await _initDatabase();

          // final count = Sqflite.firstIntValue(
          //     await _database.rawQuery("SELECT count(*) FROM $table"));
          // print('new database loaded successful , chat size $count ');
          return true;
        } else {
          // print(' backup file not downloaded');
        }
      } else {
        // print('no backup result found!!');
      }
    } catch (e) {
      _database = await _initDatabase();
      // print(e);
    }
    return false;
  }

  Future<DeleteUserModel> uploadDb(token) async {
    Database db = await instance.database;
    final count =
        Sqflite.firstIntValue(await db.rawQuery("SELECT count(*) FROM $table"));
    if (count > 0) {
      String path = join(await getDatabasesPath(), _databaseName);
      return await ApiRepository().uploadDbFile(token, File(path));
    } else {
      return null;
    }
  }

  logout(token) async {
    String path = join(await getDatabasesPath(), _databaseName);
    await ApiRepository().uploadDbFile(token, File(path));

    Database db = await instance.database;
    await db.rawQuery('DELETE from $table');
    await db.rawQuery('DELETE from $grouptable');
    await db.rawQuery('DELETE from $recentlist');
    await db.rawQuery('DELETE from $recentgrouplist');
    await db.rawQuery('DELETE from $calllist');
  }

  Future deleteConnection(cId) async {
    Database db = await instance.database;
    final result = await db.delete(recentlist);
    // final result = await db.rawQuery('DELETE from $recentlist');
    print('deleted count $result');
    // await db.rawQuery('DELETE from $recentlist WHERE $Id=$cId');
  }
}
