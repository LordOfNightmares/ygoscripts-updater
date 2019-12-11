import hashlib
import os

from methods.git_methods import create_folder


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
    cbs_temp_path = create_folder('ygocdbs')
    try:
        os.makedirs('script')
    except:
        pass
    return path, git_url, root, 'script', cbs_temp_path
