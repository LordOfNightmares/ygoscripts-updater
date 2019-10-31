# for file in os.listdir(".."):
#     if file.endswith('.cdb'):
#         print(file)
from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.ext.declarative import declarative_base


class Database:
    Base = declarative_base()
    engine = create_engine('sqlite:///' + '../' + )
    metadata = MetaData(bind=engine)


class Datas(Database.Base):
    __table__ = Table('datas', Database.metadata, autoload=True)


class Texts(Database.Base):
    __table__ = Table('texts', Database.metadata, autoload=True)


Database.file = "file.cdb"
