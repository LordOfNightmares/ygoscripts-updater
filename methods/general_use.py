class DynamicParams:
    def __init__(self, default_dict, kwargs_priority=False):
        self.__kwargs_priority = kwargs_priority
        self.__default = default_dict
        self.__dictionary = {}

    def __arguments(self, args):
        for arg in args:
            self.__dictionary[list(self.__dictionary)[args.index(arg)]] = arg
        # print("args:", len(self.__dictionary), self.__dictionary)

    def __key_arguments(self, kwargs):
        for k, v in kwargs.items():
            if k in self.__dictionary.keys():
                self.__dictionary[k] = v
        # print("kwargs:", len(self.__dictionary), self.__dictionary)

    def update(self, *args, **kwargs):
        self.__dictionary.update(self.__default)
        # print(self.__dictionary)
        if self.__kwargs_priority:
            self.__arguments(args)
            self.__key_arguments(kwargs)
        else:
            if len(args) < len(self.__dictionary):
                self.__key_arguments(kwargs)
            self.__arguments(args)

    def get(self):
        if self.__dictionary == {}:
            self.__dictionary.update(self.__default)
        return self.__dictionary


def convert_bytes(num):
    """
    this function will convert bytes to MB.... GB... etc
    """
    for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if num < 1024.0:
            # return "%3.1f, %s" % (num, x)
            return num, x
        num /= 1024.0


def list_compare(list1, list2):
    check = False
    for m in list1:
        for n in list2:
            if m == n:
                check = True
                return check
    return check
