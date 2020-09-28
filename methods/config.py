import os

import yaml

from methods.GeneralMethods import create_folder


class EngineUriMeta:
    """
    Object for defining the database variables.
    """
    dialect = 'sqlite'
    driver = None
    user = None
    password = None
    host = None
    port = None
    database = None


class YamlManager:
    def __init__(self, path_to_file):
        self.file = path_to_file
        self.data = None

    def write(self, data=None, append=False):
        if data:
            self.data = data
        if append:
            yaml.dump(self.data, open(self.file, 'a'))
        else:
            yaml.dump(self.data, open(self.file, 'w'))

    def load(self):
        try:
            self.data = yaml.load(open(self.file), Loader=yaml.FullLoader)
            if self.data is None:
                self.data = {}
            return self.data
        except FileNotFoundError:
            with open(self.file, 'w') as fp:
                pass
            return self.load()
        except:
            raise


class Config:
    def __init__(self, yaml_conf):
        self.yaml_config = YamlManager(yaml_conf)
        self.yaml_config_load = self.yaml_config.load()
        self.store_temp_cbs = create_folder('ygocdbs')
        self.store_repos = 'ygorepos'
        self.store_script = 'script'

        def rearrange_list(lst1, lst2):
            if lst1[0] is not None:
                return lst1 + list(set(lst2) - set(lst1))
            else:
                return lst2

        repos = os.listdir(self.store_repos)
        self.cdbs = rearrange_list(self.yaml_config_load['Repositoriy-priority']['cdb'], repos)
        self.script = rearrange_list(self.yaml_config_load['Repositoriy-priority']['script'], repos)

# def merge(output, dbs=None, merge_form=True):
#     if dbs is None:
#         raise Exception('No Databases found')
#     engine_names = ['sqlite:///{}'.format(db) for db in dbs]
#     engines = [create_engine(engine_name) for engine_name in engine_names]
#
#     out_engine = create_engine('sqlite:///{}'.format(output))
#     Tables(engines[0]).meta.create_all(out_engine)
#
#     db1 = DatabaseMethods(out_engine)
#     print("Databases merge in alphabet order")
#     print("Merge by adding only:", merge_form)
#
#     for engine in tqdm(engines):
#         db2 = DatabaseMethods(engine)
#         merge_db(db1, db2, merge_form)
