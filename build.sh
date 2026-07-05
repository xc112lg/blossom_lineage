  #!/bin/bash
# --- Optimized RBE Configuration for AOSP Builds ---
# Recommendations based on your current setup and performance best practices
rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf kernel/xiaomi/blossom
rm -rf vendor/lineage
#rm -rf build
rm -rf TMP_PATCHES
#rm -rf frameworks/base
sudo apt update >/dev/null 2>&1
sudo apt install patchelf -y >/dev/null 2>&1
rm -rf .repo/local_manifests
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests.git -b lunaris .repo/local_manifests
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  >/dev/null 2>&1
. build/envsetup.sh
#export WITH_GMS=true

export WITH_GMS=false
# export WITH_GMS_COMMS_SUITE := false
# export WITH_PIXEL_LAUNCHER := false
# export TARGET_USE_GPHOTOS := false
# export TARGET_USE_WALLPAPERS := false
# 1. Add the datetime import right after the contextlib import

sed -i 's|tar xfp $PARAM_BOOTANIMATION_TAR -C $INTERMEDIATES|python3 -c "import tarfile; tarfile.open(\\\"$PARAM_BOOTANIMATION_TAR\\\").extractall(path=\\\"$INTERMEDIATES\\\")"|' vendor/lineage/bootanimation/gen-bootanimation.sh
sed -i '/Command:.*buildFlagInternal/c\            Command: `${buildFlagInternal} --maps-file ${in} --quiet --declarations-only get && : > ${out}`,' build/soong/aconfig/build_flags/init.go
sed -i '/^import subprocess$/a from datetime import datetime, timezone' build/soong/scripts/gen_build_prop.py && sed -i '/config\["Date"\] = subprocess.check_output/,/config\["DateUtc"\] = subprocess.check_output/c\  dt = datetime.fromtimestamp(int(raw_date), timezone.utc)\n  config["Date"] = dt.strftime("%a %b %d %H:%M:%S UTC %Y")\n  config["DateUtc"] = str(int(raw_date))' build/soong/scripts/gen_build_prop.py
export TARGET_USES_PICO_GAPPS=true
export TARGET_INCLUDE_VIA=true
export TARGET_INCLUDE_REVAMPED=true
sed -i '$a -include vendor/evolution-priv/keys/keys.mk' device/xiaomi/blossom/lineage_blossom.mk
#sed -i '\|vendor/extras/prebuilt/product/fonts,\$(TARGET_COPY_OUT_PRODUCT)/fonts|d' vendor/extras/evolution.mk
#sed -i '/<item>com.android.nfc<\/item>/d' frameworks/base/core/res/res/values/policy_exempt_apps.xml
#cat frameworks/base/core/res/res/values/policy_exempt_apps.xml

export RBE_LOG=DEBUG
export RBE_VERBOSE=1

lunch lineage_blossom-bp4a-eng
m installclean
#m clean #once
m bacon
curl -sf https://raw.githubusercontent.com/xc112lg/blossom_lineage/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
#curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom/upevo.sh | bash >/dev/null 2>&1
