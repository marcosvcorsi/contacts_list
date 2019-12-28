import 'package:contacts_list/models/contact.dart';
import 'package:path/path.dart';
import "package:sqflite/sqflite.dart";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts_list.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE contacts("
          "id INTEGER PRIMARY KEY, "
          "name TEXT, "
          "email TEXT, "
          "phone TEXT, "
          "img TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;

    contact.id = await dbContact.insert("contacts", contact.toMap());

    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;

    List<Map> listMap = await dbContact.query("contacts",
        columns: ["id", "name", "email", "phone", "img"],
        where: "id = ?",
        whereArgs: [id]);

    if (listMap.length > 0) {
      return Contact.fromMap(listMap.first);
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;

    return await dbContact.delete("contacts", where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;

    return await dbContact.update("contacts", contact.toMap(),
        where: "id = ?", whereArgs: [contact.id]);
  }

  Future<List> findAllContacts() async {
    Database dbContact = await db;

    List listMap = await dbContact.rawQuery("SELECT * FROM contacts");

    List<Contact> listContact = List();

    for(Map map in listMap) {
      listContact.add(Contact.fromMap(map));
    }

    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;

    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM contacts"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}
