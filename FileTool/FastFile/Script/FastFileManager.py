import os
import shutil
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

class FastFileManager:
    def __init__(self, ignore_files=None, ignore_dirs=None, ignore_exts=None, max_workers=8):
        """
        :param ignore_dirs: list[str] 忽略的目录名
        :param ignore_exts: list[str] 忽略的文件扩展名（小写），比如 ['.tmp', '.log']
        :param ignore_files: list[str] 绝对路径，忽略指定的文件
        :param max_workers: int 多线程最大线程数，用于并行拷贝
        """
        self.ignore_dirs = set(ignore_dirs) if ignore_dirs else set()
        self.ignore_exts = set(e.lower() for e in ignore_exts) if ignore_exts else set()
        self.ignore_files = set(os.path.abspath(f) for f in ignore_files) if ignore_files else set()
        self.max_workers = max_workers

    def _should_ignore(self, path):
        abspath = os.path.abspath(path)
        if abspath in self.ignore_files:
            return True
        basename = os.path.basename(path)
        if basename in self.ignore_dirs:
            return True
        if os.path.isfile(path):
            _, ext = os.path.splitext(path)
            if ext.lower() in self.ignore_exts:
                return True
        return False

    def _copy_file(self, src_dst):
        src, dst = src_dst
        if os.path.exists(dst):
            if os.path.getmtime(src) <= os.path.getmtime(dst):
                return
        shutil.copy2(src, dst)

    def backup_directory(self, source_dir, backup_dir):
        source_dir = os.path.abspath(source_dir)
        backup_dir = os.path.abspath(backup_dir)

        if not os.path.isdir(source_dir):
            raise ValueError(f"Source directory '{source_dir}' does not exist.")

        tasks = []
        for root, dirs, files in os.walk(source_dir):
            dirs[:] = [d for d in dirs if d not in self.ignore_dirs]

            rel_path = os.path.relpath(root, source_dir)
            backup_path = os.path.join(backup_dir, rel_path)
            os.makedirs(backup_path, exist_ok=True)

            for file in files:
                full_src = os.path.join(root, file)
                if self._should_ignore(full_src):
                    continue
                full_dst = os.path.join(backup_path, file)
                tasks.append((full_src, full_dst))

        total = len(tasks)
        print(f"Start backing up {total} files with {self.max_workers} threads...")

        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = [executor.submit(self._copy_file, task) for task in tasks]

            completed = 0
            for _ in as_completed(futures):
                completed += 1
                percent = completed / total * 100
                bar_len = 30
                filled_len = int(bar_len * completed // total)
                bar = '=' * filled_len + '-' * (bar_len - filled_len)
                print(f"\rBacking up files: [{bar}] {percent:.1f}%", end='')
                sys.stdout.flush()

        print()

    def mirror_copy_to_existing(self, source_dir, target_dir):
        source_dir = os.path.abspath(source_dir)
        target_dir = os.path.abspath(target_dir)

        if not os.path.isdir(source_dir):
            raise ValueError(f"Source directory '{source_dir}' does not exist.")
        if not os.path.isdir(target_dir):
            raise ValueError(f"Target directory '{target_dir}' does not exist.")

        tasks = []
        for root, dirs, files in os.walk(source_dir):
            dirs[:] = [d for d in dirs if d not in self.ignore_dirs]

            rel_path = os.path.relpath(root, source_dir)
            target_path = os.path.join(target_dir, rel_path)
            if not os.path.exists(target_path):
                print(f"Warning: Target subdirectory '{target_path}' does not exist. Skipping.")
                continue

            for file in files:
                full_src = os.path.join(root, file)
                if self._should_ignore(full_src):
                    continue
                full_dst = os.path.join(target_path, file)
                if not os.path.exists(full_dst):
                    raise FileNotFoundError(f"Target file '{full_dst}' does not exist.")
                tasks.append((full_src, full_dst))

        total = len(tasks)
        print(f"Start mirroring copy of {total} files...")

        for idx, (src, dst) in enumerate(tasks, 1):
            shutil.copy2(src, dst)
            percent = idx / total * 100
            bar_len = 30
            filled_len = int(bar_len * idx // total)
            bar = '=' * filled_len + '-' * (bar_len - filled_len)
            print(f"\rMirroring files: [{bar}] {percent:.1f}%", end='')
            sys.stdout.flush()

        print()

    def delete_directory(self, target_dir):
        target_dir = os.path.abspath(target_dir)
        if os.path.exists(target_dir):
            print(f"Delete {target_dir} recursively.")
            shutil.rmtree(target_dir)

    def replace_directory(self, source_dir, target_dir):
        source_dir = os.path.abspath(source_dir)
        target_dir = os.path.abspath(target_dir)

        if not os.path.isdir(source_dir):
            raise ValueError(f"Source directory '{source_dir}' does not exist.")

        if os.path.exists(target_dir):
            print(f"Deleting target directory '{target_dir}' ...")
            shutil.rmtree(target_dir)

        print(f"Copying source directory '{source_dir}' to target '{target_dir}' ...")

        for root, dirs, files in os.walk(source_dir):
            dirs[:] = [d for d in dirs if d not in self.ignore_dirs]

            rel_path = os.path.relpath(root, source_dir)
            target_path = os.path.join(target_dir, rel_path)
            os.makedirs(target_path, exist_ok=True)

            for file in files:
                full_src = os.path.join(root, file)
                if self._should_ignore(full_src):
                    continue
                full_dst = os.path.join(target_path, file)
                shutil.copy2(full_src, full_dst)

        print("Replace directory done.")

    def backup_subset_from_target(self, subset_dir, target_dir, backup_dir):
        subset_dir = os.path.abspath(subset_dir)
        target_dir = os.path.abspath(target_dir)
        backup_dir = os.path.abspath(backup_dir)

        if not os.path.isdir(subset_dir):
            raise ValueError(f"Subset directory '{subset_dir}' does not exist.")
        if not os.path.isdir(target_dir):
            raise ValueError(f"Target directory '{target_dir}' does not exist.")

        tasks = []
        for root, dirs, files in os.walk(subset_dir):
            dirs[:] = [d for d in dirs if d not in self.ignore_dirs]

            rel_path = os.path.relpath(root, subset_dir)
            target_root = os.path.join(target_dir, rel_path)
            backup_root = os.path.join(backup_dir, rel_path)

            for file in files:
                if any(file.lower().endswith(ext) for ext in self.ignore_exts):
                    continue
                full_src = os.path.join(root, file)
                if self._should_ignore(full_src):
                    continue
                target_file = os.path.join(target_root, file)
                if os.path.exists(target_file) and os.path.isfile(target_file):
                    backup_file = os.path.join(backup_root, file)
                    tasks.append((target_file, backup_file))

        print(f"Backing up {len(tasks)} files from target to backup...")

        for src, dst in tasks:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(src, dst)

        print("Backup done.")
