import logging
import traceback
from datetime import datetime

from database.DatabaseMethods import database_operations
from methods import config
from methods.GeneralMethods import time_it, list_diff
from methods.GeneralStructs import Temp
from methods.copy_method import get_scripts, set_scripts, Cache, cdb_copy
from methods.prep.git import preparation


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
        database_operations()
    except Exception:
        logging.exception(traceback.format_exc())
        with open("error.txt", 'a') as error_file:
            error_file.write(f'{datetime.now().strftime("%d/%m/%Y | %H:%M:%S |")}\n{traceback.format_exc()}\n\n')
    finally:
        input("Press enter to leave")
