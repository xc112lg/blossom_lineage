  #!/bin/bash
# --- Optimized RBE Configuration for AOSP Builds ---

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
    echo "✓ Loaded .env from current directory"
elif [ -f ../.env ]; then
    export $(cat ../.env | grep -v '#' | xargs)
    echo "✓ Loaded .env from parent directory"
else
    echo "⚠ .env file not found"
fi
git config --global url."https://${GH_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
# Recommendations based on your current setup and performance best practices
rm -rf .repo/local_manifests/
rm -rf device/xiaomi
rm -rf kernel/xiaomi/blossom
rm -rf vendor/lineage
rm -rf hardware/mediatek
rm -rf TMP_PATCHES
#rm -rf frameworks/base
sudo apt update >/dev/null 2>&1
sudo apt install patchelf -y >/dev/null 2>&1
rm -rf .repo/local_manifests
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --depth=1
git clone https://$GH_TOKEN@github.com//xc112lg/blossom_manifest.git -b a1 .repo/local_manifests
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
source <(curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/lunaris/rbe8.sh)  >/dev/null 2>&1
. build/envsetup.sh
#export WITH_GMS=true
curl -L https://github.com/xc112lg/android_hardware_mediatek/commit/b8a9f24f9ff6e8de021fa33fc65520571fcf7478.patch | git -C hardware/mediatek am
#curl -L https://github.com/xc112lg/android_hardware_mediatek/commit/957c81f341c68497d1d1b45fc1b5808a1bca17c2.patch | git -C hardware/mediatek am

export WITH_GMS=false
export EVO_BUILD_TYPE=Unofficial
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

lunch lineage_blossom-bp4a-user
m installclean
#m clean #once
m bacon
curl -sf https://raw.githubusercontent.com/xc112lg/blossom_lineage/refs/heads/main/upevo.sh  | bash >/dev/null 2>&1
#curl -sf https://raw.githubusercontent.com/xc112lg/scripts/refs/heads/blossom/upevo.sh | bash >/dev/null 2>&1
