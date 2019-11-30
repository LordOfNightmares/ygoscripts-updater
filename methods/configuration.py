import yaml


class Config:
    def __init__(self, file):
        self.file = file

    def update(self, data):
        yaml.dump(data, open(self.file, 'w'))

    def load(self):
        return yaml.load(open(self.file), Loader=yaml.FullLoader)
