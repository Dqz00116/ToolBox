#!/usr/bin/env python3
import os
import sys
import subprocess
import tempfile
import zipfile
from pathlib import Path
import shutil


def run_dwarfdump(file_path: str):
    """Run dwarfdump and extract UUID"""
    try:
        result = subprocess.check_output(
            ["dwarfdump", "--uuid", file_path],
            stderr=subprocess.STDOUT
        ).decode("utf-8")
        uuid = result.split()[1]
        return uuid
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] Failed to run dwarfdump: {e.output.decode('utf-8')}")
        sys.exit(1)


def extract_macho_from_ipa(ipa_path: str) -> str:
    """Extract Mach-O executable path from IPA"""
    temp_dir = tempfile.mkdtemp()
    with zipfile.ZipFile(ipa_path, "r") as zip_ref:
        zip_ref.extractall(temp_dir)

    payload_dir = Path(temp_dir) / "Payload"
    apps = list(payload_dir.glob("*.app"))
    if not apps:
        apps = list(payload_dir.glob("**/*.app"))
    if not apps:
        print("[ERROR] Cannot find .app directory in IPA")
        sys.exit(1)

    app_dir = apps[0]
    macho_files = [f for f in app_dir.iterdir() if f.is_file() and not f.suffix]
    if not macho_files:
        print("[ERROR] Cannot find Mach-O executable inside IPA")
        sys.exit(1)
    return str(macho_files[0])


def extract_dsym(dsym_zip: str) -> str:
    """Extract dSYM from .dSYM.zip"""
    temp_dir = tempfile.mkdtemp()
    with zipfile.ZipFile(dsym_zip, "r") as zip_ref:
        zip_ref.extractall(temp_dir)

    dsym_files = list(Path(temp_dir).glob("*.dSYM"))
    if not dsym_files:
        dsym_files = list(Path(temp_dir).glob("**/*.dSYM"))
    if not dsym_files:
        print("[ERROR] Cannot find .dSYM inside ZIP")
        sys.exit(1)
    return str(dsym_files[0])


def check_dsym_match(app_path: str, dsym_path: str):
    """Check if dSYM matches IPA or Mach-O"""
    macho_path = app_path

    if app_path.endswith(".ipa"):
        macho_path = extract_macho_from_ipa(app_path)

    if dsym_path.endswith(".zip"):
        dsym_path = extract_dsym(dsym_path)

    print(f"[INFO] Mach-O Path: {macho_path}")
    print(f"[INFO] dSYM Path: {dsym_path}")

    macho_uuid = run_dwarfdump(macho_path)
    dsym_uuid = run_dwarfdump(dsym_path)

    print(f"[INFO] Mach-O UUID: {macho_uuid}")
    print(f"[INFO] dSYM UUID: {dsym_uuid}")

    if macho_uuid == dsym_uuid:
        print("\033[92m[OK] dSYM matches this app!\033[0m")
    else:
        print("\033[91m[FAIL] dSYM does NOT match this app!\033[0m")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage:")
        print("  python check_dsym.py <ipa_or_macho_path> <dsym_or_dsymzip_path>")
        sys.exit(1)

    app_path = sys.argv[1]
    dsym_path = sys.argv[2]

    if not os.path.exists(app_path):
        print(f"[ERROR] File not found: {app_path}")
        sys.exit(1)
    if not os.path.exists(dsym_path):
        print(f"[ERROR] File not found: {dsym_path}")
        sys.exit(1)

    check_dsym_match(app_path, dsym_path)
