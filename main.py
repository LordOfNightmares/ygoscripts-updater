from pony.orm import Database

from sql.Connection import DbAuth

db = Database()
dbAuth = dict(DbAuth('config.yaml').load())
db.bind(**dbAuth['sqlite'])
