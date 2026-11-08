#!/system/bin/sh
#The following three drivers are already loaded in rc.
#If you want to reload, uninstall them first
echo "Uninstalling xhci_mtk_hcd_tv driver..."
rmmod xhci_mtk_hcd_tv
if [ $? -ne 0 ]; then
    echo "Failed to unload xhci_mtk_hcd_tv driver."
fi

echo "Uninstalling mtu3 driver..."
rmmod mtu3
if [ $? -ne 0 ]; then
    echo "Failed to unload mtu3 driver."
fi

echo "Uninstalling phy_mtk_tphy_tv driver..."
rmmod phy_mtk_tphy_tv
if [ $? -ne 0 ]; then
    echo "Failed to unload phy_mtk_tphy_tv driver."
fi

#Reloading the driver
echo "Loading phy_mtk_tphy_tv driver..."
insmod /lib/modules/phy-mtk-tphy-tv.ko
if [ $? -ne 0 ]; then
    echo "Failed to load phy_mtk_tphy_tv driver."
fi

echo "Loading mtu3 driver..."
insmod /lib/modules/mtu3.ko mtu3_dev_en=0
if [ $? -ne 0 ]; then
    echo "Failed to load mtu3 driver."
fi

echo "Loading xhci_mtk_hcd_tv driver..."
insmod /lib/modules/xhci-mtk-hcd-tv.ko
if [ $? -ne 0 ]; then
    echo "Failed to load xhci_mtk_hcd_tv driver."
fi
