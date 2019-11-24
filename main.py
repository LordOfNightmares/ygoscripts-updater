from pprint import pprint

from sqlalchemy import create_engine

from database.DatabaseMethods import DatabaseMethods

engine = create_engine('sqlite:///test1.cdb')
db = DatabaseMethods(engine)

pprint(db.get_select_all('texts'))
