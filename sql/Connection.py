class DbAuth:
    def __init__(self, file):
        from ruamel.yaml import YAML
        self.yaml = YAML()
        self.file = file

    def update(self, data):
        self.yaml.dump(data, open(self.file, 'w'))

    def load(self):
        return self.yaml.load(open(self.file))
