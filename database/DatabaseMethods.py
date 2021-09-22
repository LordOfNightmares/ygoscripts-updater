from database.meta import EngineUri, DB
from database.reflect import Datas, Texts, reflect
from methods.GeneralMethods import time_it


def id(item):
    return getattr(item, [key for key in vars(item).keys() if key == 'id'][0])


@time_it
def merge(dbs):
    merged = {}
    for db in dbs:
        for table in dbs[0].reflected_tables:
            if table.__tablename__ not in merged:
                merged.update({table.__tablename__: None})
            query = db.Session().query(table)
            select = {id(item): item._asdict() for item in query.all()}
            if merged[table.__tablename__] is None:
                merged[table.__tablename__] = select.copy()
            merged[table.__tablename__].update(select)
    return merged


def add_to_db(db, data):
    session = db.Session()
    try:
        for table in db.reflected_tables:
            for val in data[table.__tablename__].values():
                session.add(table(**val))
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


# @time_it
def load_database(db_path, reflected_tables=None):
    if reflected_tables is None:
        reflected_tables = [Datas, Texts]
    engine = EngineUri()
    db = DB()
    engine.database = db_path
    db.load_engine(engine)
    db.MetaData.bind = db.engine
    db.reflected_tables = reflected_tables
    # reflect(db.reflected_tables, database=db)
    for table in db.reflected_tables:
        reflect(table, database=db)
    return db
