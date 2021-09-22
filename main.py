import logging
import os
import traceback
from datetime import datetime

from sqlalchemy import create_engine

from database import DatabaseMethods
from methods import config
from methods.GeneralMethods import time_it, list_diff
from methods.GeneralStructs import Temp
from methods.copy_method import get_scripts, set_scripts, Cache, cdb_copy
from methods.prep.git import preparation


def merge_cdbs():
    cdbs = sorted(["/".join([Temp.conf.store_temp_cbs, file]) for file in os.listdir(Temp.conf.store_temp_cbs)],
                  reverse=True)
    dbs = [DatabaseMethods.load_database(cdb) for cdb in cdbs]

    if len(cdbs) == 0:
        return
    name = Temp.conf.data['Output-cdb']
    try:
        os.remove(name)
    except:
        pass
    dbs[0].MetaData.create_all(create_engine(f'sqlite:///{name}'))
    output_cdb = DatabaseMethods.load_database(name)
    merge = DatabaseMethods.merge(dbs)
    DatabaseMethods.add_to_db(output_cdb, merge)


def clean_script_cache(directories, cache):
    cp = cache.all().copy()
    roots = [root for root in cp if root is not None]
    for root in list_diff(roots, directories):
        if root is not None and root in cp:
            logging.info(f'Removed: {root}')
            cache.remove(root)


@time_it
def scripts(conf):
    pre_cache = Cache('p_cache.bin')
    # print(pre_cache)
    paths = conf.paths()
    for i, path in enumerate(paths):
        if path is not None:
            Temp.path = path
            Temp.prio = i
            get_scripts(pre_cache)
            cdb_copy(path)
            # if len(scriptCache.all()) == 0:
            #     print(cache.remove(cache.out_path))
            #
    clean_script_cache(paths, pre_cache)
    # print(pre_cache)
    out_cache = Cache('o_cache.bin')
    Temp.path = 'script'
    set_scripts(pre_cache, out_cache)
    out_cache.save('o_cache.bin')
    pre_cache.save('p_cache.bin')


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s| %(threadName)s | %(levelname)-5s| %(message)s',
                        level=logging.INFO,
                        datefmt="%H:%M:%S")
    try:
        preparation()
        Temp.conf = config.Config('config.yaml')
        scripts(Temp.conf)
        merge_cdbs()
    except Exception:
        with open("error.txt", 'a') as error_file:
            error_file.write(f'{datetime.now().strftime("%d/%m/%Y | %H:%M:%S |")}\n{traceback.format_exc()}\n\n')
    finally:
        input("Press enter to leave")
