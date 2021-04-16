import logging
import os
import shutil
from pathlib import Path
from pprint import pprint

from tqdm import tqdm

from methods.Concurrency import threaded
from methods.GeneralMethods import md5


@threaded(workers=16)
def files_get(*args, **kwargs):
    file = args[0]
    conf = kwargs['conf']
    root = kwargs['root']
    to_path = kwargs['to_path']
    scripts_from = kwargs['scripts_from']
    from_path = kwargs['from_path']
    cache_p = kwargs['cache_p']
    cache_t = kwargs['cache_t']
    progressbar = kwargs['progressbar']
    try:
        # logging.info(f'Reflecting {_class.__tablename__} from {self.database.engine}')
        if file.endswith('.lua'):
            from_folder = os.path.join(root, file)
            if (file in cache_t[scripts_from] and os.path.getmtime(from_folder) != os.path.getmtime(scripts_from)) \
                    or (file not in cache_t[scripts_from]):
                hash = md5(from_folder)
                model = {file: {"hash": hash,
                                "time": os.path.getmtime(from_folder)}}
                cache_t[scripts_from].update(model)
                fipp = [model.items() <= cache_p.data[patch].items()
                        for patch in conf.yaml_config_load['Patches']
                        if patch in cache_p.data][0]
                ip = scripts_from in conf.yaml_config_load['Patches']
                fi = not model.items() <= cache_p.data[scripts_from].items()
                fifp = not ip and fi
                fitt = ip and fi
                if (not fipp and fitt) or (not fipp and fifp):
                    cache_p.data[scripts_from].update(model)
                    shutil.copy(from_folder, to_path)
            # if file in cache_t[scripts_from] and os.path.getmtime(from_folder) == cache_p.data[scripts_from][file]['time']:
            #     pass
            progressbar.update(1)
        # logging.info(f"{from_folder}")
    except:
        logging.exception(f'Item:{file}')


def counter(conf):
    folders = conf.yaml_config_load['Patches'] + [os.path.join(conf.store_repos, folder) for folder in conf.script]
    count = [file for folder in folders
             for root, dirs, files in os.walk(str(folder))
             if '.git' not in root
             for file in files
             if file.endswith('.lua')]
    return len(count)


class CopyManager:
    """
    Manager class for copying files in folders and caching their differences.
    """

    def __init__(self, checksums, conf):
        self.conf = conf
        checksums.load()
        self.cache_p = checksums
        self.priority = [0, 0]
        self.cache_t = {i: {} for i in self.conf.yaml_config_load['Patches'] + self.conf.script}
        for i in self.cache_t:
            if i not in self.cache_p.data:
                self.cache_p.data[i] = {}
        for i in self.cache_p.data.copy():
            if i not in self.cache_t:
                self.cache_p.data.pop(i)
        self.bar = tqdm(total=counter(self.conf), desc="Copying")

    # @time_it
    def cdb_copy(self, file_to_path, file_from_path):
        if file_from_path not in self.conf.yaml_config_load['Patches']:
            file_from_path = os.path.join(self.conf.store_repos, file_from_path)
        else:
            file_from_path = file_from_path
        listdir = os.listdir(file_to_path)
        self.cdb_path = os.path.join(self.conf.store_repos, file_from_path)
        for root, dirs, files in os.walk(str(file_from_path)):
            if '.git' not in root:
                for file in [f + ".cdb" for f in sorted([Path(f).stem for f in files if f.endswith('.cdb')])]:
                    if file not in listdir and file.endswith('.cdb'):
                        shutil.copy(os.path.join(root, file), file_to_path)
                        os.rename(os.path.join(file_to_path, file),
                                  os.path.join(file_to_path, f"{self.priority[0]}{self.priority[1]}{file}"))
                        self.priority[1] += 1
        self.priority[0] += 1

    # @time_it
    def script_copy(self, to_path, scripts_from):
        if scripts_from not in self.conf.yaml_config_load['Patches']:
            from_path = os.path.join(self.conf.store_repos, scripts_from)
        else:
            from_path = scripts_from
        for root, dirs, files in os.walk(str(from_path)):
            if '.git' not in root:
                # ThreadingFile(files).get(conf=self.conf,
                #                          root=root,
                #                          to_path=to_path,
                #                          from_path=from_path,
                #                          scripts_from=scripts_from,
                #                          cache_p=self.cache_p,
                #                          cache_t=self.cache_t,
                #                          progressbar=self.bar)
                files_get(files,
                          conf=self.conf,
                          root=root,
                          to_path=to_path,
                          from_path=from_path,
                          scripts_from=scripts_from,
                          cache_p=self.cache_p,
                          cache_t=self.cache_t,
                          progressbar=self.bar)

    # @time_it
    def clean_cache(self, to_path):
        script_files = os.listdir(to_path)
        for folder, files in self.cache_p.data.items():
            for file, hash in files.copy().items():
                if file not in self.cache_t[folder]:
                    try:
                        temp_path = '\\'.join([to_path, file])
                        try:
                            if md5(temp_path) == self.cache_p.data[folder][file]:
                                os.remove(temp_path)
                        except Exception as e:
                            print(e)
                        try:
                            self.cache_p.data[folder].pop(file)
                        except Exception as e:
                            print(e)
                    except:
                        pass
                    finally:
                        print(f"{file}:\t{hash} removed")
        for folder, files in self.cache_p.data.copy().items():
            if len(self.cache_p.data[folder]) == 0:
                self.cache_p.data.pop(folder)
        for file in script_files:
            count = 0
            for k, v in self.cache_p.data.items():
                if file in v:
                    count += 1
            if count == 0:
                os.remove('\\'.join([to_path, file]))
        self.cache_p.write()
        print()
        pprint({k: len(val) for k, val in self.cache_p.data.items()})
