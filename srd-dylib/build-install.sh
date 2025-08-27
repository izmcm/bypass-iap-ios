#!/bin/zsh

# Caminhos
SRC="bypass-iap.m"
DYLIB="bypass-iap.dylib"
NAME="bypass-iap"

echo "Compilling $SRC to $DYLIB..."
xcrun -sdk iphoneos clang \
    -arch arm64 \
    -dynamiclib \
    -o "$DYLIB" \
    "$SRC" \
    -framework Foundation \
    -framework StoreKit

echo "Signing $DYLIB..."
codesign --force -s - "$DYLIB"

if srdtool research dylib list | grep -q "$NAME"; then
    echo "Uninstalling existing $NAME..."
    srdtool research dylib uninstall "$NAME"
fi

echo "Installing $DYLIB in the SRD..."
srdtool research dylib install "./$DYLIB"

echo "Build and installation completed!"

echo "Injecting $DYLIB into the system..."
srdtool research launchctl inject --user --system "$NAME"