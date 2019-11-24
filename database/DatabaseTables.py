from sqlalchemy import MetaData


class Tables:
    def __init__(self, engine):
        self.meta = MetaData()
        self.meta.reflect(bind=engine)
        self.texts = self.meta.tables['texts']
        self.datas = self.meta.tables['datas']


class TempTable(object):
    pass
