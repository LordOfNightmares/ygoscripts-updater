import yaml


class Config:
    def __init__(self, file):
        self.file = file

    def update(self, data, append=False):
        if append:
            yaml.dump(data, open(self.file, 'a'))
        else:
            yaml.dump(data, open(self.file, 'w'))

    def load(self):
        return yaml.load(open(self.file), Loader=yaml.FullLoader)
