from sqlalchemy import MetaData
from sqlalchemy.ext.declarative import declarative_base


class DatabasePreLoad:
    def __init__(self, engine):
        self.Base = declarative_base()
        self.metadata = MetaData(bind=engine)

