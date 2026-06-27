# Netcore N30 Pro ImmortalWrt Patches

This repository keeps the Netcore N30 Pro adaptation files for ImmortalWrt.

The adaptation was extracted and organized from the official firmware adaptation files. This repository does **not** vendor the full ImmortalWrt source tree. Clone the official ImmortalWrt source tree, switch to the ImmortalWrt version, tag, branch, or commit you want to build, then apply the Netcore N30 Pro adaptation from this repository.

## Repository Layout

```text
Netcore-N30-Pro-patch-for-OpenWrt/
├── README.md
├── patches/
│   └── 0001-Add-Netcore-N30-Pro-support.patch
└── scripts/
    └── apply-netcore-n30pro.sh
```

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
bash ../Netcore-N30-Pro-patch-for-OpenWrt/scripts/apply-netcore-n30pro.sh ../Netcore-N30-Pro-patch-for-OpenWrt
```

After applying the adaptation, select `Netcore N30 Pro` in `make menuconfig` and build ImmortalWrt normally.

## Patch Applying Flow

The apply script is designed to work across different ImmortalWrt versions.

When the script is executed from the ImmortalWrt source root, it performs the following steps:

1. Check that the current directory looks like an ImmortalWrt source tree.
2. Check that `patches/*.patch` exists in this repository.
3. Try normal `git apply` first. This is mainly for source trees that are close to the original patch base.
4. If normal `git apply` fails, try `git apply --3way`. This may work when the source tree has only small changes and Git has the required base blobs.
5. If both patch modes fail, fall back to keyword-based insertion.
6. In keyword-based mode, the script:
   - extracts `mt7981b-netcore-n30-pro.dts` from the patch file;
   - inserts `netcore,n30-pro` into `target/linux/mediatek/filogic/base-files/etc/board.d/02_network`;
   - inserts `netcore,n30-pro` into `target/linux/mediatek/filogic/base-files/etc/hotplug.d/ieee80211/11_fix_wifi_mac`;
   - inserts `Device/netcore_n30-pro` into `target/linux/mediatek/image/filogic.mk`.
7. Finally, the script verifies that the DTS, image target, network defaults, and Wi-Fi MAC handling entries all exist.

If the output ends with:

```text
Netcore N30 Pro adaptation applied successfully.
```

then the adaptation has been applied successfully.

## About Patch Failures

When applying this repository to newer ImmortalWrt versions, the first two patch modes may print messages such as:

```text
patch does not apply
repository lacks the necessary blob to perform 3-way merge
```

These messages do not always mean the adaptation failed. They only mean the traditional patch context no longer matches the target source tree.

If the script then switches to keyword-based insertion and finishes with `Netcore N30 Pro adaptation applied successfully.`, the adaptation is successful.

## Notes

- This repository does not lock ImmortalWrt to a specific version.
- Use the ImmortalWrt version, tag, branch, or commit that matches your build target.
- Run the apply script with `bash` to avoid executable-permission problems when the script was created or edited from the GitHub web UI.
- The patch currently touches the Netcore N30 Pro DTS, image definition, network defaults, and Wi-Fi MAC handling files.
- If upstream changes the same DTS, image, network, or Wi-Fi MAC files too much, keyword-based insertion may still fail. In that case, resolve the target tree manually, build-test it, then refresh the patch.

## Refresh Patch

From a patched ImmortalWrt tree:

```sh
git diff > ../Netcore-N30-Pro-patch-for-OpenWrt/patches/0001-Add-Netcore-N30-Pro-support.patch
```
