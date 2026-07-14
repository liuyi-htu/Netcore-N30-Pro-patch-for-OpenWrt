#!/usr/bin/env bash
set -euo pipefail

PATCH_REPO="${1:-../Netcore-N30-Pro-patch-for-OpenWrt}"

DTS_FILE="target/linux/mediatek/dts/mt7981b-netcore-n30-pro.dts"
IMAGE_FILE="target/linux/mediatek/image/filogic.mk"
NET_FILE="target/linux/mediatek/filogic/base-files/etc/board.d/02_network"
WIFI_MAC_FILE="target/linux/mediatek/filogic/base-files/etc/hotplug.d/ieee80211/11_fix_wifi_mac"

need_file() {
  [ -f "$1" ] || {
    echo "缺少文件：$1"
    echo "请在 ImmortalWrt 源码根目录执行本脚本。"
    exit 1
  }
}

need_file "$IMAGE_FILE"
need_file "$NET_FILE"
need_file "$WIFI_MAC_FILE"

echo "========== Apply Netcore N30 Pro adaptation =========="
echo "Patch repo: $PATCH_REPO"

if [ -f "$DTS_FILE" ] \
  && grep -q "define Device/netcore_n30-pro" "$IMAGE_FILE" \
  && grep -q "netcore,n30-pro" "$NET_FILE" \
  && grep -q "netcore,n30-pro" "$WIFI_MAC_FILE"; then
  echo "Netcore N30 Pro adaptation already exists. Nothing to do."
  exit 0
fi

shopt -s nullglob
PATCHES=("$PATCH_REPO"/patches/*.patch)
shopt -u nullglob

if [ "${#PATCHES[@]}" -eq 0 ]; then
  echo "没有找到补丁文件：$PATCH_REPO/patches/*.patch"
  exit 1
fi

if git apply --check --whitespace=fix "${PATCHES[@]}"; then
  git apply --whitespace=fix "${PATCHES[@]}"
  echo "Applied with git apply."
elif git apply --3way --check --whitespace=fix "${PATCHES[@]}"; then
  git apply --3way --whitespace=fix "${PATCHES[@]}"
  echo "Applied with git apply --3way."
else
  echo "git apply failed. Falling back to keyword-based insertion."

  python3 - "$PATCH_REPO" <<'PY_N30'
import re
import sys
from pathlib import Path

patch_repo = Path(sys.argv[1])
dts_file = Path("target/linux/mediatek/dts/mt7981b-netcore-n30-pro.dts")
image_file = Path("target/linux/mediatek/image/filogic.mk")
net_file = Path("target/linux/mediatek/filogic/base-files/etc/board.d/02_network")
wifi_mac_file = Path("target/linux/mediatek/filogic/base-files/etc/hotplug.d/ieee80211/11_fix_wifi_mac")

for f in [image_file, net_file, wifi_mac_file]:
    if not f.exists():
        raise SystemExit(f"缺少目标文件：{f}")

def read(path):
    return path.read_text(encoding="utf-8", errors="replace")

def write(path, text):
    path.write_text(text, encoding="utf-8")

# 1. Extract the new DTS file from the patch.
if not dts_file.exists():
    patch_files = sorted((patch_repo / "patches").glob("*.patch"))
    if not patch_files:
        raise SystemExit(f"没有找到补丁文件：{patch_repo}/patches/*.patch")

    dts_lines = []
    collecting = False

    for patch in patch_files:
        for line in read(patch).splitlines():
            if line.startswith("+++ b/target/linux/mediatek/dts/mt7981b-netcore-n30-pro.dts"):
                collecting = True
                continue
            if collecting and line.startswith("diff --git "):
                break
            if collecting and line.startswith("+") and not line.startswith("+++"):
                dts_lines.append(line[1:])
        if dts_lines:
            break

    if not dts_lines:
        raise SystemExit("无法从 patch 中提取 mt7981b-netcore-n30-pro.dts")

    dts_file.parent.mkdir(parents=True, exist_ok=True)
    write(dts_file, "\n".join(dts_lines) + "\n")
    print(f"Created {dts_file}")
else:
    print(f"{dts_file} already exists")

def insert_case_token(path, token, before_tokens):
    text = read(path)
    if token in text:
        print(f"{token} already exists in {path}")
        return

    for before in before_tokens:
        pattern = rf"^(\s*){re.escape(before)}(\|\\|\))"
        match = re.search(pattern, text, flags=re.M)
        if match:
            insert = f"{match.group(1)}{token}|\\\n"
            text = text[:match.start()] + insert + text[match.start():]
            write(path, text)
            print(f"Inserted {token} into {path}")
            return

    raise SystemExit(f"无法在 {path} 中找到插入锚点：{before_tokens}")

# 2. Network defaults.
insert_case_token(
    net_file,
    "netcore,n30-pro",
    ["netcore,n60", "netcore,n60-pro", "mediatek,mt7981-rfb", "netis,nx30v2"],
)

# 3. Wi-Fi MAC handling.
insert_case_token(
    wifi_mac_file,
    "netcore,n30-pro",
    ["netis,nx31", "netis,nx32u"],
)

# 4. Image device definition.
text = read(image_file)
if "define Device/netcore_n30-pro" in text:
    print(f"Device/netcore_n30-pro already exists in {image_file}")
else:
    block = """
define Device/netcore_n30-pro
  DEVICE_VENDOR := Netcore
  DEVICE_MODEL := N30 Pro
  DEVICE_DTS := mt7981b-netcore-n30-pro
  DEVICE_DTS_DIR := ../dts
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware
  KERNEL_IN_UBI := 1
  UBINIZE_OPTS := -E 5
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  IMAGE_SIZE := 117248k
  IMAGES += factory.bin
  IMAGE/factory.bin := append-ubi | check-size $$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += netcore_n30-pro
"""

    anchors = [
        "TARGET_DEVICES += netcore_n60-pro\n",
        "define Device/netcraze_nap-630\n",
        "define Device/netgear_eax17\n",
        "define Device/netis_nx30v2\n",
    ]

    for anchor in anchors:
        pos = text.find(anchor)
        if pos != -1:
            if anchor.startswith("TARGET_DEVICES"):
                pos += len(anchor)
                text = text[:pos] + block + text[pos:]
            else:
                text = text[:pos] + block + "\n" + text[pos:]
            write(image_file, text)
            print(f"Inserted Device/netcore_n30-pro into {image_file}")
            break
    else:
        raise SystemExit(f"无法在 {image_file} 中找到设备定义插入锚点")
PY_N30
fi

[ -f "$DTS_FILE" ] || { echo "DTS not generated: $DTS_FILE"; exit 1; }
grep -q "define Device/netcore_n30-pro" "$IMAGE_FILE" || { echo "Device definition missing in $IMAGE_FILE"; exit 1; }
grep -q "netcore,n30-pro" "$NET_FILE" || { echo "Network config missing in $NET_FILE"; exit 1; }
grep -q "netcore,n30-pro" "$WIFI_MAC_FILE" || { echo "Wi-Fi MAC config missing in $WIFI_MAC_FILE"; exit 1; }

echo "Netcore N30 Pro adaptation applied successfully."
