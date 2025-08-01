
import os
import sys
import argparse

script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir not in sys.path:
    sys.path.append(script_dir)

from AssetVariationManager import get_project_root, AssetVariationManager

def main():
    parser = argparse.ArgumentParser(description="Asset Variation Command Tool")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-u", "--use", action="store_true", help="use asset variation")
    group.add_argument("-r", "--revert", action="store_true", help="revert asset variation")
    group.add_argument("-s", "--save", action="store_true", help="save static asset variation")

    args = parser.parse_args()

    project_root = get_project_root()
    manager = AssetVariationManager(project_root)

    if args.use:
        manager.use_asset_variation()
    elif args.revert:
        manager.revert_asset_variation()
    elif args.save:
        manager.copy_static_asset_variation(True)

if __name__ == "__main__":
    main()
