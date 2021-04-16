import logging
import os
import subprocess
import traceback
from datetime import datetime
from tempfile import TemporaryDirectory

from sqlalchemy import create_engine

from database import DatabaseMethods
from methods.config import Config, YamlManager
from methods.copy_method import CopyManager
from updater import power_shell


def copying(copy):
    for folder_path in conf.script:
        copy.script_copy(conf.store_script, folder_path)
        copy.cdb_copy(conf.store_temp_cbs, folder_path)
    for folder in conf.yaml_config_load['Patches'][::-1]:
        copy.script_copy(conf.store_script, str(folder))
        copy.cdb_copy(conf.store_temp_cbs, str(folder))
    copy.bar.close()
    copy.clean_cache(conf.store_script)


def merge_cdbs():
    cdbs = ["/".join([conf.store_temp_cbs, x]) for x in os.listdir(conf.store_temp_cbs)]
    dbs = [DatabaseMethods.load_database(cdb) for cdb in cdbs]
    name = conf.yaml_config_load['Output-cdb']
    try:
        os.remove(name)
    except:
        pass
    dbs[0].MetaData.create_all(create_engine(f'sqlite:///{name}'))
    output_cdb = DatabaseMethods.load_database(name)
    merge = DatabaseMethods.merge(dbs)
    DatabaseMethods.add_to_db(output_cdb, merge)


def pre():
    try:
        os.makedirs('ygorepos')
    except:
        pass
    try:
        os.makedirs('script')
    except:
        pass


def install():
    print('\nPlease wait checking for Git installation if not installed it will be installed now.')
    with TemporaryDirectory() as tmp:
        abs = os.path.join(os.path.abspath(tmp), 'git_install.ps1')
        with open(abs, 'w') as file:
            file.write(power_shell())
        bashCommand = 'powershell -executionpolicy bypass -File ' + abs
        subprocess.run(bashCommand)
    if len(os.listdir("ygorepos")) == 0:
        subprocess.run("git_set.bat")
    if input("Update Repos(y/n)") == 'y':
        subprocess.run("git_pull.bat")


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s:\t%(threadName)s:%(levelname)s:\t%(message)s',
                        level=logging.INFO,
                        datefmt="%H:%M:%S")
    try:
        pre()
        install()

        conf = Config('config.yaml')
        checksums = YamlManager('checksum.yaml')
        copy = CopyManager(checksums, conf)
        copying(copy)

        merge_cdbs()
    except Exception:
        with open("error.txt", 'a') as error_file:
            error_file.write(f'{datetime.now().strftime("%d/%m/%Y | %H:%M:%S |")}\n{traceback.format_exc()}\n\n')
    finally:
        input("Press enter to leave")
