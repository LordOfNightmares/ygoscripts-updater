from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import create_session


# Create and engine and get the metadata
# Base = declarative_base()


# Reflect each database table we need to use, using metadata


# Base = declarative_base()
# engine = create_engine('sqlite:///test1.cdb')
# metadata = MetaData(bind=engine)

class DatabaseMethods:
    def __init__(self, engine):
        self.Base = declarative_base()
        self.metadata = MetaData(bind=engine)
        self.session = create_session(bind=engine)

    def close(self):
        self.session.close()

    def get_all(self):
        q = self.session.query(Texts)
        from pprint import pprint
        for res in q.all():
            pprint(res.__dict__)


engine1 = create_engine('sqlite:///test1.cdb')
engine2 = create_engine('sqlite:///test2.cdb')
db = DatabaseMethods(engine2)


class Datas(db.Base):
    __table__ = Table('datas', db.metadata, autoload=True)


class Texts(db.Base):
    __table__ = Table('texts', db.metadata, autoload=True)


db.get_all()
