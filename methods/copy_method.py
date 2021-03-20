import concurrent.futures
import os
import shutil
from pathlib import Path
from pprint import pprint

from tqdm import tqdm

from methods.Concurrency import Concurrency
from methods.GeneralMethods import md5


class ThreadingFile(Concurrency):
    def get(self,
            conf=None,
            root=None,
            to_path=None,
            from_path=None,
            scripts_from=None,
            cache_p=None,
            cache_t=None,
            progressbar=None):
        self.conf = conf
        self.root = root
        self.to_path = to_path
        self.scripts_from = scripts_from
        self.from_path = from_path
        self.cache_p = cache_p
        self.cache_t = cache_t
        self.progressbar = progressbar
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            for args, instance in zip(self.args, executor.map(self.send_instance, self.args)):
                try:
                    if instance:
                        self.all_instances.append(instance)
                except:
                    pass
        return self.all_instances

    def process(self, item):
        file = item[0]
        # logging.info(f'Reflecting {_class.__tablename__} from {self.database.engine}')
        from_folder = os.path.join(self.root, file)
        hash = md5(from_folder)
        if file.endswith('.lua') and file not in self.cache_t[self.scripts_from]:
            self.cache_t[self.scripts_from].update({file: hash})
            fipp = [{file: hash}.items() <= self.cache_p.data[patch].items()
                    for patch in self.conf.yaml_config_load['Patches']
                    if patch in self.cache_p.data][0]
            ip = self.scripts_from in self.conf.yaml_config_load['Patches']
            fi = not {file: hash}.items() <= self.cache_p.data[self.scripts_from].items()
            fifp = not ip and fi
            fitt = ip and fi
            if not fipp and fitt:
                self.cache_p.data[self.scripts_from].update({file: hash})
                shutil.copy(from_folder, self.to_path)
            if not fipp and fifp:
                self.cache_p.data[self.scripts_from].update({file: hash})
                shutil.copy(from_folder, self.to_path)
            self.progressbar.update(1)

    # logging.info(f"{from_folder}")


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
                ThreadingFile(files).get(conf=self.conf,
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
