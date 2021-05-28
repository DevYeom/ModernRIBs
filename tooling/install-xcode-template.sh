#!/usr/bin/env sh

# Configuration
XCODE_TEMPLATE_DIR=$HOME'/Library/Developer/Xcode/Templates/File Templates/ModernRIB'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy ModernRIBs file templates into the local ModernRIBs template directory
xcodeTemplate () {
  echo "==> Copying up ModernRIB Xcode file templates..."

  if [ -d "$XCODE_TEMPLATE_DIR" ]; then
    rm -R "$XCODE_TEMPLATE_DIR"
  fi
  mkdir -p "$XCODE_TEMPLATE_DIR"

  cp -R $SCRIPT_DIR/*.xctemplate "$XCODE_TEMPLATE_DIR"
  cp -R $SCRIPT_DIR/ModernRIB.xctemplate/ownsView/* "$XCODE_TEMPLATE_DIR/ModernRIB.xctemplate/ownsViewwithXIB/"
  cp -R $SCRIPT_DIR/ModernRIB.xctemplate/ownsView/* "$XCODE_TEMPLATE_DIR/ModernRIB.xctemplate/ownsViewwithStoryboard/"
}

xcodeTemplate

echo "==> ... success!"
echo "==> ModernRIB have been set up. In Xcode, select 'New File...' to use ModernRIB templates."
