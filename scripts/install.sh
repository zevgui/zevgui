#!/bin/bash

BOLD='\033[1m' && DIM='\033[2m' && LINK='\033[0;34m' && NC='\033[0m' && RED='\033[0;31m' && GREEN='\033[0;32m' # Readability over maintainability! :D

trap "echo -e \"${RED}\nExecution interrupted.. Exiting program${NC}\";exit 1" SIGINT

ACCEPTED="no"
while getopts "y" opt; do
  case $opt in
    y)
      ACCEPTED="yes"
      ;;
    \?)
      echo -e "${RED}Invalid option provided!${NC}" >&2
      exit 1
      ;;
  esac
done

# Prompt
echo -e "This script will install external libraries required for building apps in directory \"$PWD/ext.\""
echo -e "${BOLD}By running this script, you acknowledge and agree to the terms of the licenses for the following programs:${NC}\n"
echo -e "1. Webview (LIB)${NC}           : ${LINK}https://github.com/webview/webview${NC}"
echo -e "2. Microsoft Edge WebView2${NC} : ${LINK}https://developer.microsoft.com/en-us/microsoft-edge/webview2${NC}"

if [[ "$ACCEPTED" != "yes" ]]; then
  prompt="$(echo -e "\nDo you accept the terms of these licenses? (yes/no): ")"
  read -p "$prompt" response
  if [[ "$response" != "yes" ]]; then
    echo -e "\n${RED}Rejected: You must accept the licenses to proceed with the installation.${NC}"
    exit 1
  fi
fi

echo -e "\n${GREEN}Permission granted! Installing files...${NC}"
echo -e "${DIM}(note: it might take few seconds to minutes, once done the script will exit with code 0)${NC}"

# Webview Installation

# Quick Cleanup
rm -rf ./ext/deps
rm -rf ./ext/windows/webview2

mkdir -p ext && cd ext

mkdir -p webview

curl -sSLo "./webview/webview.h" "https://raw.githubusercontent.com/webview/webview/master/webview.h"
curl -sSLo "./webview/webview.cc" "https://raw.githubusercontent.com/webview/webview/master/webview.cc"
curl -sSLo "./webview/webview_mingw_support.h" "https://raw.githubusercontent.com/webview/webview/master/webview_mingw_support.h"

# MS WEBVIEW2

{
    rm -rf webview2
    mkdir webview2 && cd webview2
    clear
    echo "Fetching Webview2... (1/2)"
    wget https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2
    unzip Microsoft.Web.WebView2
} &> /dev/null # silent

# Pretty much only what's required from build
mkdir -p ../windows && mkdir -p ../windows/webview2
mv ./build/native/x64/WebView2Loader.dll ../windows/webview2/w2x64.dll
mv ./build/native/x64/WebView2Loader.dll.lib ../windows/webview2/w2x64.dll.lib
mv ./build/native/x64/WebView2LoaderStatic.lib ../windows/webview2/w2x64.static.lib
mv ./build/native/x86/WebView2Loader.dll ../windows/webview2/w2x86.dll
mv ./build/native/x86/WebView2Loader.dll.lib ../windows/webview2/w2x86.dll.lib
mv ./build/native/x86/WebView2LoaderStatic.lib ../windows/webview2/w2x86.static.lib
mv ./build/native/arm64/WebView2Loader.dll ../windows/webview2/w2_arm64.dll
mv ./build/native/arm64/WebView2Loader.dll.lib ../windows/webview2/w2_arm64.dll.lib
mv ./build/native/arm64/WebView2LoaderStatic.lib ../windows/webview2/w2_arm64.static.lib
mv ./build/native/include ../windows/webview2/include
mv ./build/native/include-winrt ../windows/webview2/include-winrt

# Cleanup
cd ../ && rm -rf webview2

# Gracefully finished!