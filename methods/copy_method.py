import os
import shutil

from methods.GeneralMethods import md5
from methods.configuration import Config


class CopyManager:
    def __init__(self, checker):
        self.checker = Config(checker)
        try:
            self.config = self.checker.load()
        except:
            self.config = {}

        self.memory = {}
        self.memory_hashes = []
        self.priority = 0
        self.old_hashed = [hash for folder in self.config
                           if folder in self.config for hash
                           in self.config[folder].values()]
        if len(self.old_hashed) == 0:
            self.hash_trigger = True
        else:
            self.hash_trigger = False

    def _load_conf(self, file_from_path):
        try:
            self.config.update({file_from_path: self.config[file_from_path]})
        except:
            self.config.update({file_from_path: {}})

    def script_copy(self, file_to_path, file_from_path):
        self.memory = {**self.config[file_from_path], **self.memory}
        self.__scopy(file_to_path, file_from_path)
        self.checker.update(self.config)
        self.priority += 1

    def hashing(self, file_to_path, file_from_path):
        listdir = os.listdir(file_to_path)
        self._load_conf(file_from_path)
        if self.hash_trigger:
            self.old_hashed = [hash for folder in self.config
                               if folder in self.config for hash
                               in self.config[folder].values()]
        for root, dirs, files in os.walk(file_from_path):
            if '.git' not in root:
                for file in files:
                    if file.endswith('.lua'):
                        file_from_folder = '\\'.join([root, file])
                        current_file_checksum = md5(file_from_folder)
                        try:
                            if file in listdir and current_file_checksum not in self.old_hashed:
                                os.remove('\\'.join([file_to_path, file]))
                                print(file, current_file_checksum, "removed")
                        except:
                            pass
                        self.config[file_from_path].update({file: current_file_checksum})
        self.checker.update(self.config)

    def __scopy(self, file_to_path, file_from_path):
        listdir = os.listdir(file_to_path)
        for root, dirs, files in os.walk(file_from_path):
            if '.git' not in root:
                # for file in tqdm(files, desc="[{}]: {}".format('scripts', root), unit=' files'):
                for file in files:
                    file_from_folder = '\\'.join([root, file])
                    current_file_checksum = md5(file_from_folder)
                    if file.endswith('.lua'):
                        if file not in listdir and current_file_checksum in self.memory.values():
                            shutil.copy(file_from_folder, file_to_path)

    def clean_up(self, file_to_path):
        listdir = os.listdir(file_to_path)
        cards = [card for folder in self.config for card in self.config[folder]]
        for file in listdir:
            current_file_checksum = md5(os.path.join(file_to_path, file))
            if current_file_checksum not in self.memory.values():
                for folder in self.config:
                    if file in self.config[folder] and current_file_checksum not in self.config[folder]:
                        del self.config[folder][file]
            if file.endswith('.lua') and file not in cards:
                print(file)
                os.remove('\\'.join([file_to_path, file]))

    def cdb_copy(self, file_to_path, file_from_path):
        listdir = os.listdir(file_to_path)
        for root, dirs, files in os.walk(file_from_path):
            if '.git' not in root:
                # for file in tqdm(files, desc="[{}]: {}".format('cdbs', root), unit=' files'):
                for file in files:
                    if file not in listdir and file.endswith('.cdb'):
                        shutil.copy(os.path.join(root, file), file_to_path)
                        os.rename(os.path.join(file_to_path, file),
                                  os.path.join(file_to_path, str(self.priority) + file))
