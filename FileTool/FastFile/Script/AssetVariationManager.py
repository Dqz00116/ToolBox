import os
import FastFileManager

from configparser import ConfigParser

class CaseConfigParser(ConfigParser):
    def optionxform(self, optionstr):
        return optionstr

def get_project_root():
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)
    return os.path.dirname(os.path.dirname(script_dir))


class AssetVariationManager(FastFileManager.FastFileManager):
    def __init__(self, project_root, ignore_dirs=None, ignore_exts=None):
        self.init_paths(project_root)
        self.config = CaseConfigParser()
        self.config.read(self.config_path)
        super().__init__(ignore_files=[self.config_path], ignore_dirs=ignore_dirs, ignore_exts=ignore_exts)

    def init_path(self, path):
        if not os.path.exists(path):
            print(f"Warning: Path '{path}' does not exist.")
            answer = input("Do you want to create it? (y/n): ").strip().lower()
            if answer == 'y':
                try:
                    os.makedirs(path)
                    print(f"Created directory: {path}")
                except Exception as e:
                    raise RuntimeError(f"Failed to create directory '{path}': {e}")
            else:
                raise FileNotFoundError(f"Path '{path}' does not exist and was not created.")
        else:
            print(f"Find path: {path}")
        return path

    def init_paths(self, project_root):
        print(f"Project root directory: {project_root}")
        self.content_path = self.init_path(os.path.join(project_root, "Content"))
        self.resources_path = self.init_path(os.path.join(project_root, "Content", "Resources"))
        self.localization_path = self.init_path(os.path.join(self.content_path, "Localization"))
        self.config_path = self.init_path(os.path.join(self.resources_path , "csv", "Variation.ini"))
        self.asset_source_path = self.init_path(os.path.join(self.content_path, "MyProject"))
        self.asset_variation_path = self.init_path(os.path.join(self.content_path, "L10N", "en", "MyProject"))
        self.variation_base_path = self.init_path(os.path.join(project_root, "AssetVariation"))
        self.variation_backpack_path = self.init_path(os.path.join(self.variation_base_path, "MyProject"))
        self.variation_ZH_backpack_path = self.init_path(os.path.join(self.variation_backpack_path, "zh"))
        self.variation_EN_backpack_path = self.init_path(os.path.join(self.variation_backpack_path, "en"))
        self.variation_localization_path = self.init_path(os.path.join(self.variation_base_path, "Localization"))
        self.variation_resources_path = self.init_path(os.path.join(self.variation_base_path, "Resources"))
        
    def copy_static_asset_variation(self, bSave = False):
        variation = "zh" if self.is_use_asset_variation() else "en"
        print(f"Start copying the {variation } assets.")
        operate_list = [
            (self.resources_path, os.path.join(self.variation_resources_path, variation)),
            (self.localization_path, os.path.join(self.variation_localization_path, variation))
        ]
        
        for dest, src in operate_list:
            from_path, to_path = (src, dest) if bSave else (dest, src)
            self.replace_directory(from_path, to_path)
                 
    def switch_asset_variation_status(self):
        self.config["Status"]["bUseVariationAsset"] = 'True' if not self.is_use_asset_variation() else 'False'
        with open(self.config_path , 'w') as config_file:
            self.config.write(config_file)

    def is_use_asset_variation(self) -> bool:
        return self.config["Status"]["bUseVariationAsset"].strip().lower() in ['true', '1', 'yes', 'y', 'on']
        
    def use_asset_variation(self):
        if self.is_use_asset_variation():
            print('already "Asset Variation" is in use, no need to switch again.')
            return
        
        self.backup_subset_from_target(self.asset_source_path, self.asset_variation_path, self.variation_ZH_backpack_path)
        self.backup_directory(self.asset_variation_path, self.variation_EN_backpack_path)
        self.mirror_copy_to_existing(self.asset_variation_path, self.asset_source_path)
        self.copy_static_asset_variation()
        self.delete_directory(self.asset_variation_path)
        self.switch_asset_variation_status()
        
    def revert_asset_variation(self):
        if not self.is_use_asset_variation():
            print('already "Asset Variation" is not in use, no need to switch again.')
            return
        
        self.mirror_copy_to_existing(self.variation_ZH_backpack_path, self.asset_source_path)
        self.replace_directory(self.variation_EN_backpack_path, self.asset_variation_path)
        self.copy_static_asset_variation()
        self.delete_directory(self.variation_backpack_path)
        self.switch_asset_variation_status()