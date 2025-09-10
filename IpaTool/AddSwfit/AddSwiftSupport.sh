#!/bin/bash

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            ipa_path)          ipaPath=${VALUE} ;; # Format: "Path/to/app.ipa"
            archive_path)      archivePath=${VALUE} ;; # Format: "Path/to/app.xcarchive"
            toolchain_path)    toolchainPath=${VALUE} ;; # Format: "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.0/iphoneos"
            *)
    esac

done

# Derived Variables
script_dir=$(cd "$(dirname "$0")" && pwd)
ipaDirectory=$(readlink -f $(dirname "$ipaPath"))
ipaName=$(basename "$ipaPath")
ipaName_no_extension="${ipaName%.*}"
zipName=${ipaName/.ipa/.zip}
appName=""
zipSuffix=-unzipped
unzippedDirectoryName=${ipaName_no_extension}${zipSuffix}
newIpaSuffix=-with-swift-support
newIpaName=${ipaName}${newIpaSuffix}
swiftSupportPath=SwiftSupport/iphoneos
ipaSwiftSupportDirectory=${ipaDirectory}/${unzippedDirectoryName}/${swiftSupportPath}

# Changes the .ipa file extension to .zip and unzips it
function unzipIPA {
    mv "${ipaDirectory}/${ipaName}" "${ipaDirectory}/${zipName}"
    unzip "${ipaDirectory}/${zipName}" -d "${ipaDirectory}/${unzippedDirectoryName}"
}

# Copies the SwiftSupport folder from the .xcarchive into the .ipa
function copySwiftSupportFromArchiveIntoIPA {
    echo "copySwiftSupportFromArchiveIntoIPA"
    mkdir -p "$ipaSwiftSupportDirectory"
    cd "${archivePath}/${swiftSupportPath}"
    for file in *.dylib; do
        cp -v "$file" "$ipaSwiftSupportDirectory"
    done
}

# Creates the SwiftSupport folder from the Xcode toolchain and copies it into the .ipa
function copySwiftSupportFromToolchainIntoIPA {
    echo "copySwiftSupportFromToolchainIntoIPA"
    mkdir -p "$ipaSwiftSupportDirectory"
    
    echo "ipaSwiftSupportDirectory: $ipaSwiftSupportDirectory"
    echo "SwiftSupportDirectory: $script_dir/Frameworks"

    local ipa_depends_dir="${ipaDirectory}/${unzippedDirectoryName}/Payload/${appName}.app/Frameworks"

    if [ -d "$ipa_depends_dir" ] && [ -n "$(find "$ipa_depends_dir" -maxdepth 1 -name '*.dylib' -print -quit)" ]; then
        cd "$ipa_depends_dir"
        echo "Using .dylib files from: $ipa_depends_dir"
        for file in *.dylib; do
          cp -v "${toolchainPath}/${file}" "$ipaSwiftSupportDirectory"
        done
    else
        cd "${script_dir}/Frameworks"
        echo "Using .dylib files from: ${script_dir}/Frameworks"
        for file in *.dylib; do
          cp -v "${toolchainPath}/${file}" "$ipaSwiftSupportDirectory"
          cp -v "${toolchainPath}/${file}" "$ipa_depends_dir"
        done
        echo "The contents of the IPA application package have been modified, requiring re-signing."
    fi


    
}

# Adds the SwiftSupport folder from one of two sources depending on the presence of an .xcarchive
function addSwiftSupportFolder {
  if [ -z "$archivePath" ]
  then
    copySwiftSupportFromToolchainIntoIPA
  else
    copySwiftSupportFromArchiveIntoIPA
  fi
}

# Zips the new folder back up and changes the extension to .ipa
function createAppStoreIPA {
    cd "${ipaDirectory}/${unzippedDirectoryName}"
    local date_time=$(date +"%Y_%m_%d_%H_%M_%S")
    zip -r "${ipaDirectory}/${newIpaName}.zip" ./*
    mv "${ipaDirectory}/${newIpaName}.zip" "${ipaDirectory}/${newIpaName}_${date_time}.ipa"
}

# Renames original .ipa and deletes the unzipped folder
function cleanUp {
    mv "${ipaDirectory}/${zipName}" "${ipaDirectory}/${ipaName}"
    rm -r "${ipaDirectory}/${unzippedDirectoryName}"
}

# Execute Steps
unzipIPA
addSwiftSupportFolder
createAppStoreIPA
cleanUp
