# Netcore N30 Pro ImmortalWrt Patches

This repository only keeps the Netcore N30 Pro adaptation patches for ImmortalWrt.

It does not vendor the full ImmortalWrt source tree. Pick the ImmortalWrt version, tag, or branch you want, then apply the patches from this repository.

## Usage

```sh
git clone https://github.com/immortalwrt/immortalwrt.git immortalwrt-n30pro
cd immortalwrt-n30pro

# Pick any target version or branch.
git checkout v24.10.5
# git checkout openwrt-24.10
# git checkout master

git apply --3way /path/to/Netcore-n30pro-immortalwrt/patches/*.patch
```

After applying the patch, select `Netcore N30 Pro` in `make menuconfig` and build ImmortalWrt normally.

## Notes

- The patch was originally extracted from the `v24.10.5` adaptation.
- Other ImmortalWrt versions can be used as long as the surrounding `mediatek/filogic` files remain compatible.
- If upstream changes the same DTS, image, network, or Wi-Fi MAC files, `git apply --3way` may report conflicts. Resolve those conflicts in the target ImmortalWrt tree, build-test, then refresh the patch.

## Refresh Patch

From a patched ImmortalWrt tree:

```sh
git diff > /path/to/Netcore-n30pro-immortalwrt/patches/0001-Add-Netcore-N30-Pro-support.patch
```
