import os

__all__ = [file[:-3] for file in os.listdir(".") if not file.startswith("__") and file.endswith(".py")]
# print(__all__)
