# Netcore N30 Pro ImmortalWrt Patches

This repository keeps the Netcore N30 Pro adaptation patches for ImmortalWrt.

The patches were extracted and organized from the official firmware adaptation files, so this repository does **not** vendor the full ImmortalWrt source tree. Clone the official ImmortalWrt source tree, switch to the ImmortalWrt version, tag, branch, or commit you want to build, then apply the patches from this repository.

## Usage

Clone this patch repository and the official ImmortalWrt source tree in the same parent directory:

```sh
git clone https://github.com/liuyi-htu/Netcore-N30-Pro-patch-for-OpenWrt.git
git clone https://github.com/immortalwrt/immortalwrt.git immortalwrt-n30pro
cd immortalwrt-n30pro
```

Pick the target ImmortalWrt version, tag, branch, or commit you want to build:

```sh
git checkout <version-tag-branch-or-commit>
# Example:
# git checkout v25.12.0
# git checkout openwrt-24.10
# git checkout master
```

Apply the Netcore N30 Pro patches:

```sh
git apply --3way ../Netcore-N30-Pro-patch-for-OpenWrt/patches/*.patch
```

After applying the patch, select `Netcore N30 Pro` in `make menuconfig` and build ImmortalWrt normally.

## Notes

- The patch does not lock ImmortalWrt to a specific version.
- Use the ImmortalWrt version, tag, branch, or commit that matches your build target.
- Other ImmortalWrt versions can be used as long as the surrounding `mediatek/filogic` files remain compatible.
- The patch currently touches the Netcore N30 Pro DTS, image definition, network defaults, and Wi-Fi MAC handling files.
- If upstream changes the same DTS, image, network, or Wi-Fi MAC files, `git apply --3way` may report conflicts. Resolve those conflicts in the target ImmortalWrt tree, build-test, then refresh the patch.

## Refresh Patch

From a patched ImmortalWrt tree:

```sh
git diff > ../Netcore-N30-Pro-patch-for-OpenWrt/patches/0001-Add-Netcore-N30-Pro-support.patch
```
