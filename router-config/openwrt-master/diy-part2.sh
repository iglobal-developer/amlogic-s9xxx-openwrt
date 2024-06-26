#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt for Amlogic s9xxx tv box
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow
sed -i 's/nobody:\*:0:0:99999:7:::/nobody:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
grep -v "DISTRIB_DESCRIPTION=" package/base-files/files/etc/openwrt_release > tmpFile && mv tmpFile package/base-files/files/etc/openwrt_release
echo "DISTRIB_DESCRIPTION='VSocks V1.0'" >>package/base-files/files/etc/openwrt_release

sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='openwrt.master'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate

#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# coolsnowwolf default software package replaced with Lienol related software package
# rm -rf feeds/packages/utils/{containerd,libnetwork,runc,tini}
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/{containerd,libnetwork,runc,tini} feeds/packages/utils

# Add third-party software packages (The entire repository)
# git clone https://github.com/libremesh/lime-packages.git package/lime-packages
# Add third-party software packages (Specify the package)
# svn co https://github.com/libremesh/lime-packages/trunk/packages/{shared-state-pirania,pirania-app,pirania} package/lime-packages/packages
# Add to compile options (Add related dependencies according to the requirements of the third-party software package Makefile)
# sed -i "/DEFAULT_PACKAGES/ s/$/ pirania-app pirania ip6tables-mod-nat ipset shared-state-pirania uhttpd-mod-lua/" target/linux/armvirt/Makefile

# Apply patch
# git apply ../router-config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------
rm -rf package/lean/luci-theme-argon
git clone https://github.com/iglobal-developer/luci-theme-argon.git package/lean/luci-theme-argon
rm -rf package/luci
git clone https://github.com/iglobal-developer/luci.git package/luci

grep -v "luciname    = " package/luci/modules/luci-base/luasrc/version.lua  > tmpFile  && mv tmpFile package/luci/modules/luci-base/luasrc/version.lua
echo "luciname    = VPROXY" >> package/luci/modules/luci-base/luasrc/version.lua
grep -v "luciversion = " package/luci/modules/luci-base/luasrc/version.lua  > tmpFile  && mv tmpFile package/luci/modules/luci-base/luasrc/version.lua
echo "luciversion = V1.0" >> package/luci/modules/luci-base/luasrc/version.lua

sed -i 's/luci/vsocks/g' package/luci/modules/luci-base/root/www/index.html
sed -i 's/LuCI - Lua/VSocks/g' package/luci/modules/luci-base/root/www/index.html
mv package/luci/modules/luci-base/htdocs/cgi-bin/luci package/luci/modules/luci-base/htdocs/cgi-bin/vsocks

git clone -b master --depth 1 https://github.com/kuoruan/openwrt-upx.git package/openwrt-upx
git clone https://github.com/iglobal-developer/openwrt-v2ray.git package/v2ray-core
git clone -b package "https://iglobal-developer:"$GITHUB_CHECKOUT"@github.com/iglobal-developer/vsocks.git" package/vsocks-app-vproxy
# git clone -b luci2 https://github.com/kuoruan/luci-app-v2ray.git package/luci-app-v2ray
# git clone https://github.com/iglobal-developer/luci-app-multi-user.git package/luci-app-multi-user