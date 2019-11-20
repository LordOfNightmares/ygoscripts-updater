from sqlalchemy import create_engine

from DatabasePreLoad import DatabasePreLoad

engine1 = create_engine('sqlite:///test1.cdb')
load = DatabasePreLoad(engine1)
