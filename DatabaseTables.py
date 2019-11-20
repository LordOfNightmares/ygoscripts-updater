from DatabaseLoad import load
from sqlalchemy import Table


class Datas(load.Base):
    __table__ = Table('datas', load.metadata, autoload=True)


class Texts(load.Base):
    __table__ = Table('texts', load.metadata, autoload=True)
