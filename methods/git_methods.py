import os
import shutil

import git
from tqdm import tqdm


class Progress(git.RemoteProgress):
    def new_message_handler(self):
        """
        :return:
            a progress handler suitable for handle_process_output(), passing lines on to this Progress
            handler in a suitable format"""
        self.total = []
        self.pbar = None

        def handler(line):
            return self._parse_progress_line(line.rstrip())

        # end
        return handler

    def execute(self, cur_count, word, num, max_count):
        if str(self._cur_line)[:num] == word:
            if str(self._cur_line)[:num] not in self.total:
                self.total.append(str(self._cur_line)[:num])
                try:
                    self.pbar.close()
                except:
                    pass
                self.last = int(cur_count)
                self.pbar = tqdm(desc=self._cur_line[:num], total=int(max_count))
                if str(self._cur_line)[:num] != "Resolving deltas":
                    self.pbar.update(1)
            else:
                try:
                    self.pbar.update(int(cur_count) - self.last)
                    self.last = int(cur_count)
                except:
                    pass

    def update(self, op_code, cur_count, max_count=None, message=''):
        self.execute(cur_count, "Receiving objects", 17, max_count)
        self.execute(cur_count, "Resolving deltas", 16, max_count)
        self.execute(cur_count, "remote: Counting objects", 24, max_count)
        self.execute(cur_count, "remote: Compressing objects", 27, max_count)


class Repository:
    def __init__(self, DIR_NAME, REMOTE_URL, path):
        self.path = path
        self.DIR_NAME = DIR_NAME
        self.REMOTE_URL = REMOTE_URL

    def clone(self):
        try:
            print("Please wait, updating:\t", self.DIR_NAME)
            self.repo = git.Repo(self.DIR_NAME)
            self.repo.git.reset('--hard', 'origin/master')
            # ensure master is checked out
            self.repo.heads.master.checkout()
            # blast any changes there (only if it wasn't checked out)
            self.repo.git.reset('--hard', 'origin/master')
            # pull in the changes from from the remote
            if self.repo.git.clean('-nxdf'):
                print()
                print(self.repo.git.clean('-nxdf'), 'from', self.DIR_NAME)
                print("Please backup these files mentioned if you need them!")
                ans = input("Do you want to continue?(y/n)")
                while ans != "y" or ans != "n":
                    if ans == "y":
                        self.repo.git.clean('-xdf')
                        print("Files were removed from", self.DIR_NAME)
                        break
                    if ans == "n":
                        print("Files were kept in", self.DIR_NAME)
                        break
                    ans = input("Do you want to continue?(y/n)")
            self.origin = self.repo.remote('origin')
        except:
            os.mkdir(self.DIR_NAME)
            self.repo = git.Repo.init(self.DIR_NAME)
            self.origin = self.repo.create_remote('origin', self.REMOTE_URL)

        #     self.clone()
        self.origin.fetch(progress=Progress())
        head = [ref for ref in self.origin.refs if 'origin/master' in str(ref)][0].remote_head
        self.origin.pull(head, progress=Progress())
        self.repo.close()
        print('Done:', self.DIR_NAME)


def git_clone(path, git_url, root):
    Repository(path, git_url, root).clone()


def create_folder(f_name):
    """
    creates a folder by removing the old one and its contents
    :param f_name: folder name
    :return: folder name
    """
    if f_name not in os.listdir():
        os.mkdir(f_name)
    else:
        shutil.rmtree(f_name)
        os.mkdir(f_name)
    return f_name


def clean(path):
    for root, dirs, files in os.walk(path):
        [dirs.remove(d) for d in list(dirs) if d == '.git']
        for dir in dirs:
            shutil.rmtree(os.path.join(root, dir))
        for file in files:
            if file not in os.listdir(path + '\\.git'):
                if not file.startswith('.'):
                    os.remove(os.path.join(root, file))
