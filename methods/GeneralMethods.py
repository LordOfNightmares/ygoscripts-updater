import hashlib
import os
import shutil
import time


def create_folder(f_name):
    """
    Creates a folder by removing the old one and its contents
    :param f_name: folder name
    :return: folder name
    """
    if f_name not in os.listdir():
        os.mkdir(f_name)
    else:
        shutil.rmtree(f_name)
        os.mkdir(f_name)
    return f_name


def time_it(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        val = func(*args, **kwargs)
        duration = time.time() - start_time
        print(f"Executed {func.__name__} in {duration} seconds")
        return val

    return wrapper


def smart_truncate(content: str, length: int = 100, suffix: str = '...') -> str:
    """
    :param content: String you want to truncate
    :param length: length of how much of content you want to see
    :param suffix: What to end with.
    :return: content[:length]+suffix
    """
    if len(content) >= length:
        print(content[:length])
        content = content[:length].rsplit(' ', 1)[0] + suffix
        if len(content) > length:
            return content
        else:
            return smart_truncate(content, length - 1)
    else:
        return content


def file_read(filename):
    with open(filename, encoding='UTF-8') as f:
        content = f.readlines()
    content = [x.strip() for x in content]
    return content


def merge_list_of_dicts(l1, l2, key):
    merged = {}
    for item in l1 + l2:
        if item[key] in merged:
            merged[item[key]].update(item)
        else:
            merged[item[key]] = item
    return [val for (_, val) in merged.items()]


def md5(fname):
    BLOCKSIZE = 65536
    hasher = hashlib.sha1()
    with open(fname, 'rb') as file:
        buf = file.read(BLOCKSIZE)
        while len(buf) > 0:
            hasher.update(buf)
            buf = file.read(BLOCKSIZE)
    return hasher.hexdigest()
