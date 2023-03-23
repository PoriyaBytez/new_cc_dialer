String dbName = 'flutter_contacts.db';
int dbVersion = 1;

List<String> dbCreate = [
  
  """CREATE TABLE contacts (
    id INTEGER PRIMARY KEY,
    name TEXT,
    nickName TEXT,
    work TEXT,
    phoneNumber TEXT UNIQUE,
    email TEXT,
    webSite TEXT,
    favorite TEXT,
    created TEXT
  )""",
];
