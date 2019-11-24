from pprint import pprint

from sqlalchemy import create_engine

from database.DatabaseMethods import DatabaseMethods, merge_db
from database.DatabaseTables import Tables


def merge(merge_form=True):
    engine_names = ['sqlite:///test1.cdb', 'sqlite:///test2.cdb']
    engines = [create_engine(engine_name) for engine_name in engine_names]

    out_engine = create_engine('sqlite:///output.cdb')
    Tables(engines[0]).meta.create_all(out_engine)

    db1 = DatabaseMethods(out_engine)
    print("Databases merge in alphabet order")
    print("Merge by adding only:", merge_form)
    for engine in engines:
        db2 = DatabaseMethods(engine)
        merge_db(db1, db2, merge_form)
    # print(len(db1.get_select_all('texts')))


merge()
