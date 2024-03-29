import hashlib
import os
import shutil
import time
from functools import wraps


def create_folder(path):
    """
    Creates a folder by removing the old one and its contents
    :param path: folder name
    :return: folder name
    """
    try:
        os.listdir(path)
    except:
        os.makedirs(path)
    else:
        shutil.rmtree(path)
        os.makedirs(path)
    return path


def time_it(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.process_time()
        val = func(*args, **kwargs)
        duration = time.process_time() - start_time
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


def list_diff(li1, li2):
    return list(set(li1) - set(li2)) + list(set(li2) - set(li1))


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


def str_dict_depth(str_dict: str):
    length = len(str_dict)
    depth = -2
    for i, k in enumerate(str_dict):
        if k == "{":
            depth += 1
        elif k == "}":
            if i + 1 != length and str_dict[i + 1] != ',':
                depth -= 1
    return depth


def md5(fname):
    BLOCKSIZE = 131072
    hasher = hashlib.md5()
    with open(fname, 'rb') as file:
        buf = file.read(BLOCKSIZE)
        while len(buf) > 0:
            hasher.update(buf)
            buf = file.read(BLOCKSIZE)
    return hasher.hexdigest()
