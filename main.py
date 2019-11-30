import os

from database.DatabaseMethods import merge
from methods.configuration import Config
from methods.current_project_general import cdb_copy, script_copy, pathing
from methods.git_methods import git_clone, create_folder

if __name__ == '__main__':
    conf = Config('config.yaml').load()
    chkc = Config('checksum.yaml')
    paths, git_urls, root_path, script_path = pathing(conf)
    cbs_handle = create_folder('ygocdbs')
    try:
        os.makedirs(script_path)
    except:
        pass
    try:
        checksums = chkc.load()
    except:
        checksums = {}
    for path, url in zip(paths, git_urls):
        git_clone(path, url)
        print('Moving files')
        if path != "ygorepos\Ygoproco-Live2017Links":
            script_copy(script_path, path, checksums)
        cdb_copy(cbs_handle, path)
    # print([os.path.join(os.path.abspath(tmp_dir), p) for p in os.listdir(tmp_dir)])
    merge(conf['Output-cdb'], [os.path.join(os.path.abspath(cbs_handle), p) for p in os.listdir(cbs_handle)])
    chkc.update(checksums)
