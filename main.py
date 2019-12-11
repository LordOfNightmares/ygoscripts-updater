import os

from methods.GeneralMethods import pathing
from methods.configuration import Config
from methods.copy_method import CopyManager
from methods.git_methods import git_clone


def copying(conf, copy, paths, script_path, cbs_temp_path):
    for folder in conf['Patches']:
        print('Pre patch files')
        if folder in os.listdir('.'):
            if folder not in conf['Merge-Except']['Scripts']:
                copy.script_copy(script_path, folder)
            if folder not in conf['Merge-Except']['Cdbs']:
                copy.cdb_copy(cbs_temp_path, folder)
    for path in paths:
        print('Moving files')
        if path not in conf['Merge-Except']['Scripts']:
            copy.script_copy(script_path, path)
        if path not in conf['Merge-Except']['Cdbs']:
            copy.cdb_copy(cbs_temp_path, path)


def hashing(conf, copy, paths):
    for folder in conf['Patches']:
        if folder in os.listdir('.'):
            if folder not in conf['Merge-Except']['Scripts']:
                copy.hashing(folder)

    for path in paths:
        if path not in conf['Merge-Except']['Scripts']:
            copy.hashing(path)


if __name__ == '__main__':
    conf = Config('config.yaml').load()
    paths, git_urls, root_path, script_path, cbs_temp_path = pathing(conf)
    copy = CopyManager('checksum.yaml')
    priority = 0
    # for path, url in zip(paths, git_urls):
    #     git_clone(path, url)
    # hashing
    hashing(conf, copy, paths)
    # copying
    copying(conf, copy, paths, script_path, cbs_temp_path)
    copy.clean_up(script_path)
    # print([os.path.join(cbs_temp_path, p) for p in os.listdir(cbs_temp_path)])
    # merge(conf['Output-cdb'], [os.path.join(cbs_temp_path, p) for p in os.listdir(cbs_temp_path)])
