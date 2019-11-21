from pprint import pprint

from sqlalchemy import create_engine

from database.DatabaseMethods import DatabaseMethods

engine1 = create_engine('sqlite:///test1.cdb')
engine2 = create_engine('sqlite:///test2.cdb')
engine = create_engine('sqlite:///testingvalues.cdb')
db = DatabaseMethods(engine)
'''get id'''
# for i in db.get_id(110600015, 'texts'):
#     print(dict(i))
# print(db.get_id(110600015, 'texts'))
'''add/update'''
# insert = {"id": 2, 'name': 'ok','hint': 'useless text'}
# db.add(insert,'demo')
# db.edit(insert,'demo')
'''delete'''
# db.delete(8, 'demo')
pprint(db.get_select_all('demo'))
