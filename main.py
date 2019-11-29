from sqlalchemy import create_engine

from database.DatabaseMethods import DatabaseMethods, merge_db
from database.DatabaseTables import Tables
from methods.git_methods import git_clone


def merge(merge_form=True, dbs=None):
    if dbs is None:
        dbs = ['test1.cdb', 'test2.cdb']
    engine_names = ['sqlite:///{}'.format(db) for db in dbs]
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


# merge()
git_url = ["https://github.com/Fluorohydride/ygopro-pre-script.git",
           "https://github.com/Fluorohydride/ygopro-scripts.git",
           "https://github.com/szefo09/updateYGOPro2.git"]
path = [x[x.rfind('/') + 1:x.rfind('.')] for x in git_url]
for folder, url in zip(path, git_url):
    git_clone(folder, url)
