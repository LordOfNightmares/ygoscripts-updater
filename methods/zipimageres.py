import os
import shutil
import zipfile
from tempfile import TemporaryDirectory

from PIL import Image


class Zipper:
    def __init__(self, zip_filename, path='.'):
        self.path = path
        self.zip_filename = zip_filename
        try:
            self.archive_cls = zipfile.ZipFile(os.path.join(self.path, self.zip_filename))
        except:
            self.archive_cls = zipfile.ZipFile(os.path.join(self.path, self.zip_filename), 'a', zipfile.ZIP_DEFLATED)

    def zip(self):
        path = self.zip_filename[:self.zip_filename.rfind('.')]
        shutil.make_archive(self.zip_filename, 'zip', path)
        if path in os.listdir():
            shutil.rmtree(path)

    # def resize_inner(self, size_ratio, to_format, from_format):
    #     to_format = '.' + to_format
    #     archive = zipfile.ZipFile(os.path.join(self.path, self.zip_filename), 'a')
    #     if not len(self.archive_cls.infolist()) > 0:
    #         raise MemoryError(500, "Missing zip file")
    #     for zip_entry in self.archive_cls.infolist():
    #         for form in from_format:
    #             if zip_entry.filename.endswith(form):
    #                 with self.archive_cls.open(zip_entry) as file:
    #                     self._save(size_ratio, zip_entry, file, to_format, archive)
    #     return self.path, filename

    def resize_outer(self, size_ratio, to_format, from_format):
        to_format = '.' + to_format
        filename = self.zip_filename[:self.zip_filename.rfind('.')] + "_" + to_format[1:] + ".zip"
        archive = zipfile.ZipFile(os.path.join(self.path, filename), 'w')
        if not len(self.archive_cls.infolist()) > 0:
            raise MemoryError(500, "Missing zip file")
        for zip_entry in self.archive_cls.infolist():
            for form in from_format:
                if zip_entry.filename.endswith(form):
                    with self.archive_cls.open(zip_entry) as file:
                        self._save(size_ratio, zip_entry, file, to_format, archive)
        return self.path, filename

    def _save(self, value, zip_entry, file, file_format, archive):
        def res(img, val):
            return img.resize(tuple([int(i * float(val)) for i in list(img.size)]), Image.LANCZOS)

        z_path = '/'.join(zip_entry.filename.split("/")[:-1:])
        z_filename = zip_entry.filename[zip_entry.filename.rfind('/') + 1:zip_entry.filename.rfind('.')] + file_format
        img = Image.open(file)
        img = res(img, value)
        with TemporaryDirectory() as tmp_dir:
            img_path = os.path.join(tmp_dir, z_filename)
            try:
                img.save(img_path)
            except Exception as e:
                raise Exception(400, e)
            zip_arc = os.path.join(z_path, z_filename)
            # print(img_path, zip_arc)
            try:
                archive.write(img_path, arcname=zip_arc)
            except Exception as e:
                return Exception(500, e)

# not working
# zip2 = Zipper('Image compression.zip')
# zip2.unzip_resized(0.5, ".j2k")
# zip2.zip()

# zip1 = Zipper('Image compression.zip')
# zip1.resize_outer(0.5, ".j2k")
# zip1.resize_outer(2, ".webp")

# zip2 = Zipper('Image compression.zip')
# zip2.resize_inner(0.1, ".j2k")
# zip2.resize_inner(2, ".webp")
