import os

from tqdm import tqdm

from database.DatabaseMethods import merge
from methods.GeneralMethods import pathing
from methods.configuration import Config
from methods.copy_method import CopyManager
from methods.git_methods import git_clone


def copying(conf, copy, paths, script_path, cbs_temp_path):
    val = len(conf['Patches']) + len(paths)
    progress = tqdm(total=val, desc='Copying')
    for folder in conf['Patches']:
        # print('Pre patch files')
        if folder in os.listdir('.'):
            if folder not in conf['Merge-Except']['Scripts']:
                copy.script_copy(script_path, folder)
            if folder not in conf['Merge-Except']['Cdbs']:
                copy.cdb_copy(cbs_temp_path, folder)
        progress.update(1)
    for path in paths:
        # print('Moving files')
        if path not in conf['Merge-Except']['Scripts']:
            copy.script_copy(script_path, path)
        if path not in conf['Merge-Except']['Cdbs']:
            copy.cdb_copy(cbs_temp_path, path)
        progress.update(1)
    progress.close()


def hashing(conf, copy, paths):
    val = len(conf['Patches']) + len(paths)
    progress = tqdm(total=val, desc='Hashing')
    for folder in conf['Patches']:
        if folder in os.listdir('.'):
            if folder not in conf['Merge-Except']['Scripts']:
                copy.hashing(script_path, folder)
        progress.update(1)

    for path in paths:
        if path not in conf['Merge-Except']['Scripts']:
            copy.hashing(script_path, path)
        progress.update(1)
    progress.close()


if __name__ == '__main__':
    conf = Config('config.yaml').load()
    paths, git_urls, root_path, script_path, cbs_temp_path = pathing(conf)
    copy = CopyManager('checksum.yaml')
    priority = 0
    for path, url in zip(paths, git_urls):
        git_clone(path, url, root_path)
    # hashing
    hashing(conf, copy, paths)
    # copying
    copying(conf, copy, paths, script_path, cbs_temp_path)
    copy.clean_up(script_path)
    # print([os.path.join(cbs_temp_path, p) for p in os.listdir(cbs_temp_path)])
    if conf['Output-cdb'] in os.listdir('.'):
        os.remove(conf['Output-cdb'])
    merge(conf['Output-cdb'], [os.path.join(cbs_temp_path, p) for p in os.listdir(cbs_temp_path)])
    input("Done.")
