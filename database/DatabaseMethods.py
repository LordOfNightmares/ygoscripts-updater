import os

from sqlalchemy import create_engine

from database.meta import EngineUri, DB, session_scope
from database.reflect import Datas, Texts, reflect, ReflectedTable
from methods.GeneralMethods import time_it
from methods.GeneralStructs import Temp


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


def get_dict(db):
    full = {}
    with session_scope(db.Session()) as session:
        for table in db.reflected_tables:
            try:
                query = session.query(table)
                # print()
                full.update({table.__tablename__: [i._asdict() for i in query.all()]})
            except Exception as e:
                print(f'Error: {e}')
                print(table.__tablename__)
        # print(len(query.all()))
    return full


def add_table_data(db, data):
    with session_scope(db.Session()) as session:
        for table in db.reflected_tables:
            if table.__tablename__ in data:
                for val in data[table.__tablename__].values():
                    session.add(table(**val))


def remove_filter(db):
    with session_scope(db.Session()) as session:
        keys = []
        for table in db.reflected_tables:
            if "id" in vars(table).keys():
                query = session.query(table)
                select = {id(item): item._asdict() for item in query.all() if
                          'ot' in vars(item).keys() and item.ot == 4}
                keys += list(select.keys())
                q = session.query(table).filter(table.id.in_(keys))
                q.delete()


def edit_data_filter(db):
    with session_scope(db.Session()) as session:
        for table in db.reflected_tables:
            if table.__tablename__.endswith("texts"):
                query = session.query(table)
                select = {}
                for item in query.all():
                    if 'desc' in vars(item).keys():
                        item.desc = item.desc.replace("'''", "")
                    select.update({id(item): item._asdict()})
                add_table_data(db, select)


def database_reflect_load_old(db_path, reflected_tables=None):
    if reflected_tables is None:
        reflected_tables = [Datas, Texts]
    engine = EngineUri()
    db = DB()
    engine.database = db_path
    db.load_engine(engine)
    # db.MetaData.bind = db.engine
    db.reflected_tables = reflected_tables
    for table in db.reflected_tables:
        reflect(table=table, database=db)
    return db


def database_reflect_load(db_path, reflected_tables=None):
    engine = EngineUri()
    db = DB()
    engine.database = db_path
    db.load_engine(engine)
    db.MetaData.bind = db.engine
    db.reflected_tables = []
    if reflected_tables is None:
        for table in db.engine.table_names():
            class X(ReflectedTable):
                __name__ = table
                __tablename__ = table

                def __iter__(self):
                    for k, v in self.__dict__.items():
                        yield k, v

                def __repr__(self):
                    return str(self._asdict())

            db.reflected_tables.append(X)
    else:
        db.reflected_tables = reflected_tables

    reflect(db.reflected_tables, database=db)
    return db


@time_it
def database_operations():
    # merge(dbs)
    databases = os.listdir(Temp.conf.store_temp_cbs)
    cdbs = [os.path.join(Temp.conf.store_temp_cbs, databases[0])] \
           + sorted([os.path.join(Temp.conf.store_temp_cbs, file) for file in databases], reverse=True)
    tables = [Datas, Texts]
    dbs = [database_reflect_load(cdb, tables) for cdb in cdbs]

    if len(cdbs) == 0:
        return
    name = Temp.conf.data['Output-cdb']
    try:
        os.remove(name)
    except:
        pass
    dbs[0].MetaData.create_all(create_engine(f'sqlite:///{name}'))
    output_cdb = database_reflect_load(name, tables)
    add_table_data(output_cdb, merge(dbs))
