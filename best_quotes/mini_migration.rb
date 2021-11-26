require "sqlite3"

conn = SQLite3::Database.new "test.db"
conn.execute <<SQL
create table quote (
	id INTEGER PRIMARY KEY,
	submitter varchar(30),
	attribution varchar(30),
	quote varchar(32000));
SQL