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
```

Apply the Netcore N30 Pro adaptation:

```sh
../Netcore-N30-Pro-patch-for-OpenWrt/scripts/apply-netcore-n30pro.sh ../Netcore-N30-Pro-patch-for-OpenWrt
```

After applying the adaptation, select `Netcore N30 Pro` in `make menuconfig` and build ImmortalWrt normally.

## Notes

- The patch does not lock ImmortalWrt to a specific version.
- Use the ImmortalWrt version, tag, branch, or commit that matches your build target.
- The patch currently touches the Netcore N30 Pro DTS, image definition, network defaults, and Wi-Fi MAC handling files.
- The apply script first tries normal `git apply`. If the target ImmortalWrt tree has changed and the patch context no longer matches, it falls back to keyword-based insertion.
- If upstream changes the same DTS, image, network, or Wi-Fi MAC files too much, the keyword fallback may still fail. In that case, resolve the target tree manually, build-test it, then refresh the patch.

## Refresh Patch

From a patched ImmortalWrt tree:

```sh
git diff > ../Netcore-N30-Pro-patch-for-OpenWrt/patches/0001-Add-Netcore-N30-Pro-support.patch
```
