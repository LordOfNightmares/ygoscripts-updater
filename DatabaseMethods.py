from DatabasePreLoad import DatabasePreLoad
from DatabaseTables import *
from sqlalchemy.orm import create_session


class DatabaseMethods(DatabasePreLoad):
    def __init__(self, engine):
        super().__init__(engine)
        self.session = create_session(bind=engine)

    def close(self):
        self.session.close()

    def get_all(self):
        q = self.session.query(Texts)
        from pprint import pprint
        for res in q.all():
            pprint(res.__dict__)