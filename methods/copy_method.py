import json
import logging
import os
import shutil

from tqdm import tqdm

from methods.Concurrency import threading
from methods.GeneralMethods import md5
from methods.GeneralStructs import Temp, FactoryRepo


class Cache(FactoryRepo):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class ScriptCache(FactoryRepo):
    def __init__(self):
        super().__init__()


class Script:
    def __init__(self, name=None, root=None, prio=None, checksum=None, time=None, path=None, old_path=None):
        self.root = root
        self.name = name
        self.checksum = checksum
        self.time = time
        self.prio = prio
        if path:
            self.path = path
        else:
            self.path = os.path.join(self.root, self.name)
        if old_path:
            self.old_path = old_path
        else:
            self.old_path = self.path

    def __iter__(self):
        for k, v in vars(self).items():
            yield k, v

    def __repr__(self):
        return json.dumps(self, sort_keys=True, default=lambda o: o.__dict__, indent=2)


def get_files(path):
    return {file: {'root': root,
                   'name': file,
                   'path': path,
                   'time': os.path.getmtime(path)}
            for root, dirs, files in os.walk(str(path))
            if '.git' not in root
            for file in files
            if file.endswith('.lua') and (path := os.path.join(root, file))}


def cdb_copy(path):
    tmp = 0
    for root, dirs, files in os.walk(str(path)):
        if '.git' not in root:
            for file in files:
                if file.endswith('.cdb'):
                    shutil.copy(os.path.join(root, file), Temp.conf.store_temp_cbs)
                    os.rename(os.path.join(Temp.conf.store_temp_cbs, file),
                              os.path.join(Temp.conf.store_temp_cbs, f"{Temp.prio}-{tmp}--{file}"))
                    tmp += 1


def clean_caches(directory, cache):
    cp = cache.all().copy()
    paths = [file['path'] for file in directory]
    for n, script in cp.items():
        if script.path not in paths:
            logging.info(f'Removed: {n}\t - \t{script.root}')
            cache.remove(n)


# @time_it
# noinspection PyPep8Naming,SpellCheckingInspection
def get_scripts(cache):
    files = get_files(Temp.path)
    if Temp.path in (all_cache := cache.all()):
        scriptCache = all_cache[Temp.path]
    else:
        scriptCache = ScriptCache()

    clean_caches(files.values(), scriptCache)
    if len(files) == 0:
        return None
    logging.info(f'{Temp.path} {len(files)}')
    for file in all_cache:
        if file not in files:
            scriptCache.remove(file)

    for fname, file in files.items():
        if fname not in scriptCache.all().keys():
            script = Script(fname, file['root'], Temp.prio)
        else:
            script = Script(**vars(scriptCache.get(fname)))
        if file['time'] != script.time:
            try:
                scriptCache.add(fname, script)
                script.checksum = md5(script.path)
                script.prio = Temp.prio
                script.time = os.path.getmtime(script.path)
            except Exception as e:
                print(e)

    cache.add(Temp.path, scriptCache)
    # print(vars(cache))
    return scriptCache


def delete(directory, cache):
    names = [file['name'] for file in directory]
    if len(names) == 0:
        return
    for n, file in cache.all().items():
        if n not in names:
            os.remove(file.path)
            print(f"{file.path} deleted")


# noinspection SpellCheckingInspection,PyPep8Naming
def set_scripts(p_cache, o_cache):
    files = get_files(Temp.path)
    # p_cache = sorted(p_cache.all().items(), key=lambda z: list(map(lambda x: (x[1].prio[1], x[1].prio[0]), z[1].all().items())))
    # get_scripts2(o_cache)
    # print(*p_cache)
    # print(p_cache.all().items())
    p_cache = sorted(p_cache.all().items(), key=lambda z: list(map(lambda x: x[1].prio, z[1])))
    scr1 = {}
    for n, f in dict(p_cache).items():
        for ns, s in f.all().items():
            if ns not in scr1:
                scr1.update({ns: s})

    chk = {file.name: file for file in scr1.values()}
    # print(len(scr1))
    if Temp.path in (cache := o_cache.all()):
        scriptCache = cache[Temp.path]
    else:
        scriptCache = ScriptCache()

    # cp = cache.all().copy()
    # paths = [file['path'] for file in directory]
    # for n, script in cp.items():
    #     if script.path not in paths:
    #         logging.info(f'Removed: {n}')
    #         cache.remove(n)
    # clean(files, scriptCache)
    # print(scriptCache)script.path
    cp = scriptCache.all().copy()
    for script in cp.values():
        if script.name in chk and script.path != chk[script.name].path:
            scriptCache.remove(script.name)
    progressbar = tqdm(total=len(chk), desc="Copying")
    copy_on_cache(files.items(),
                  chk=chk,
                  scriptCache=scriptCache,
                  progressbar=progressbar)
    copy_on_folder(chk.items(),
                   files=files,
                   chk=chk,
                   scriptCache=scriptCache,
                   progressbar=progressbar)
    # print(scriptCache)
    progressbar.close()
    o_cache.add(Temp.path, scriptCache)


@threading
def copy_on_cache(*args, **kwargs):
    fname = args[0][0]
    file = args[0][1]
    chk = kwargs['chk']
    scriptCache = kwargs['scriptCache']
    progressbar = kwargs['progressbar']
    if fname in chk:
        if fname not in scriptCache.all().keys():
            script = Script(**vars(chk[fname]))
        else:
            script = scriptCache.get(fname)
        progressbar.update(1)
        # print(fname)
        # print(os.path.getmtime(file['path']) == script.time, script.checksum == chk[fname].checksum)
        if os.path.getmtime(file['path']) != script.time \
                or script.checksum != chk[fname].checksum:
            # logging.info(f'New: {script.name} → {script.path}')
            scriptCache.add(fname, script)
            shutil.copy(script.path, file['path'])
            script.checksum = md5(file['path'])
            script.time = os.path.getmtime(file['path'])
            # print(os.path.getmtime(file['path']) == script.time, script.checksum == chk[fname].checksum)
    else:
        logging.info(f'Extra: | Deleted | {file["path"]}')
        os.remove(file['path'])


@threading
def copy_on_folder(*args, **kwargs):
    name = args[0][0]
    # file = args[0][1]
    files = kwargs['files']
    chk = kwargs['chk']
    scriptCache = kwargs['scriptCache']
    progressbar = kwargs['progressbar']
    if name not in files:
        script = Script(**vars(chk[name]))
        scriptCache.add(name, script)
        # print(script.prio == chk[name].prio, '\t', script.root)
        path = os.path.join(Temp.path, script.name)
        # logging.info(f'copied: {script.path} → {path}')
        shutil.copy(script.path, path)
        progressbar.update(1)
        script.checksum = md5(path)
        script.time = os.path.getmtime(path)
