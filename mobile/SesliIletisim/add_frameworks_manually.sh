#!/bin/bash
# Bu script, framework'leri manuel olarak eklemek için kullanılabilir
# Eğer xcfilelist dosyaları hala çalışmıyorsa, bu scripti Build Phases'e ekleyin

FRAMEWORKS_FOLDER_PATH="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "$FRAMEWORKS_FOLDER_PATH"

# Framework kopyalama fonksiyonu
copy_framework() {
    SRC="$1"
    if [ -e "$SRC" ]; then
        echo "Kopyalanıyor: $SRC -> $FRAMEWORKS_FOLDER_PATH"
        cp -R "$SRC" "$FRAMEWORKS_FOLDER_PATH/"
    else
        echo "UYARI: Framework bulunamadı: $SRC"
    fi
}

# Tüm frameworkleri kopyala
copy_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/KeychainAccess/KeychainAccess.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/Socket.IO-Client-Swift/SocketIO.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/Starscream/Starscream.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/Toast-Swift/Toast_Swift.framework"
copy_framework "${PODS_ROOT}/GoogleWebRTC/Frameworks/frameworks/WebRTC.framework"

echo "Framework'ler manuel olarak kopyalandı!"
