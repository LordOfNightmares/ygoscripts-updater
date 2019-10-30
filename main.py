from pony.orm import Database

db = Database()
dbAuth = dict(DbAuth('config.yaml').load())
db.bind(**dbAuth['mysql'])
