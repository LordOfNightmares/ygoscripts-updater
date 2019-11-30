import hashlib
import os
import shutil

from tqdm import tqdm


def script_copy(to_path, from_path, checksums):
    getlist = os.listdir(to_path)
    checksums.update({from_path: {}})
    for root, dirs, files in os.walk(from_path):
        if '.git' not in root:
            for file in tqdm(files, desc="[scripts]:" + str(root), unit=' files'):
                if file not in getlist and file.endswith('.lua'):
                    from_folder = '\\'.join([root, file])
                    if md5(from_folder) not in checksums[from_path]:
                        checksums[from_path].update({file: md5(from_folder)})
                        shutil.copy(from_folder, to_path)


def cdb_copy(to_path, from_path):
    from tqdm import tqdm
    getlist = os.listdir(to_path)
    for root, dirs, files in os.walk(from_path):
        if '.git' not in root:
            for file in tqdm(files, desc="[cdb]:" + str(root), unit=' files'):
                if file not in getlist and file.endswith('.cdb'):
                    shutil.copy(os.path.join(root, file), to_path)


def md5(fname):
    BLOCKSIZE = 65536
    hasher = hashlib.sha1()
    with open(fname, 'rb') as file:
        buf = file.read(BLOCKSIZE)
        while len(buf) > 0:
            hasher.update(buf)
            buf = file.read(BLOCKSIZE)
    return hasher.hexdigest()


def pathing(conf):
    git_url = conf['Git-Repositories']
    root = conf['Output-Folder']
    try:
        os.makedirs(root)
    except:
        pass
    finally:
        path = []
        for url in git_url:
            if ".git" in url:
                path.append(os.path.join(root, '-'.join(url[url.rfind('/', 0, 19) + 1:url.rfind('.')].split('/'))))
            else:
                path.append(os.path.join(root, '-'.join(url[url.rfind('/', 0, 19) + 1:].split('/'))))
    return path, git_url, root, 'script'
