#!/bin/bash

# سكريبت بناء تطبيق بوابة عملاء الألبان

set -e

echo "🚀 بدء بناء تطبيق بوابة عملاء الألبان..."

# التحقق من وجود Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js غير مثبت. يرجى تثبيت Node.js أولاً."
    exit 1
fi

# التحقق من وجود Cordova
if ! command -v cordova &> /dev/null; then
    echo "❌ Cordova غير مثبت. يرجى تثبيت Cordova أولاً:"
    echo "npm install -g cordova"
    exit 1
fi

# تثبيت التبعيات
echo "📦 تثبيت التبعيات..."
npm install

# التحقق من المتطلبات
echo "🔍 التحقق من متطلبات البناء..."
cordova requirements

# تنظيف البناء السابق
echo "🧹 تنظيف البناء السابق..."
cordova clean android

# إضافة منصة Android إذا لم تكن موجودة
if [ ! -d "platforms/android" ]; then
    echo "📱 إضافة منصة Android..."
    cordova platform add android
fi

# تحديث الإضافات
echo "🔌 تحديث الإضافات..."
cordova plugin save
cordova prepare android

# البناء حسب النوع المطلوب
BUILD_TYPE=${1:-debug}

if [ "$BUILD_TYPE" = "release" ]; then
    echo "🏗️ بناء APK للإنتاج..."
    
    # التحقق من وجود مفتاح التوقيع
    if [ ! -f "milk-portal-release-key.keystore" ]; then
        echo "⚠️ مفتاح التوقيع غير موجود. إنشاء مفتاح جديد..."
        keytool -genkey -v -keystore milk-portal-release-key.keystore -alias milk-portal -keyalg RSA -keysize 2048 -validity 10000
    fi
    
    cordova build android --release
    
    echo "✅ تم بناء APK للإنتاج بنجاح!"
    echo "📁 الملف موجود في: platforms/android/app/build/outputs/apk/release/"
    
else
    echo "🏗️ بناء APK للتطوير..."
    cordova build android --debug
    
    echo "✅ تم بناء APK للتطوير بنجاح!"
    echo "📁 الملف موجود في: platforms/android/app/build/outputs/apk/debug/"
fi

# عرض معلومات الملف المبني
APK_DIR="platforms/android/app/build/outputs/apk/$BUILD_TYPE"
if [ -d "$APK_DIR" ]; then
    echo ""
    echo "📊 معلومات الملف المبني:"
    ls -lh "$APK_DIR"/*.apk
fi

echo ""
echo "🎉 تم الانتهاء من البناء بنجاح!"

if [ "$BUILD_TYPE" = "debug" ]; then
    echo ""
    echo "💡 لتشغيل التطبيق على الجهاز:"
    echo "cordova run android"
    echo ""
    echo "💡 لبناء إصدار الإنتاج:"
    echo "./build.sh release"
fi
