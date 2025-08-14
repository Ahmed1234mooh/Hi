@echo off
REM سكريبت بناء تطبيق بوابة عملاء الألبان لنظام Windows

echo 🚀 بدء بناء تطبيق بوابة عملاء الألبان...

REM التحقق من وجود Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js غير مثبت. يرجى تثبيت Node.js أولاً.
    pause
    exit /b 1
)

REM التحقق من وجود Cordova
cordova --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Cordova غير مثبت. يرجى تثبيت Cordova أولاً:
    echo npm install -g cordova
    pause
    exit /b 1
)

REM تثبيت التبعيات
echo 📦 تثبيت التبعيات...
call npm install

REM التحقق من المتطلبات
echo 🔍 التحقق من متطلبات البناء...
call cordova requirements

REM تنظيف البناء السابق
echo 🧹 تنظيف البناء السابق...
call cordova clean android

REM إضافة منصة Android إذا لم تكن موجودة
if not exist "platforms\android" (
    echo 📱 إضافة منصة Android...
    call cordova platform add android
)

REM تحديث الإضافات
echo 🔌 تحديث الإضافات...
call cordova plugin save
call cordova prepare android

REM البناء حسب النوع المطلوب
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=debug

if "%BUILD_TYPE%"=="release" (
    echo 🏗️ بناء APK للإنتاج...
    
    REM التحقق من وجود مفتاح التوقيع
    if not exist "milk-portal-release-key.keystore" (
        echo ⚠️ مفتاح التوقيع غير موجود. يرجى إنشاء مفتاح التوقيع أولاً.
        echo keytool -genkey -v -keystore milk-portal-release-key.keystore -alias milk-portal -keyalg RSA -keysize 2048 -validity 10000
        pause
        exit /b 1
    )
    
    call cordova build android --release
    
    echo ✅ تم بناء APK للإنتاج بنجاح!
    echo 📁 الملف موجود في: platforms\android\app\build\outputs\apk\release\
    
) else (
    echo 🏗️ بناء APK للتطوير...
    call cordova build android --debug
    
    echo ✅ تم بناء APK للتطوير بنجاح!
    echo 📁 الملف موجود في: platforms\android\app\build\outputs\apk\debug\
)

echo.
echo 🎉 تم الانتهاء من البناء بنجاح!

if "%BUILD_TYPE%"=="debug" (
    echo.
    echo 💡 لتشغيل التطبيق على الجهاز:
    echo cordova run android
    echo.
    echo 💡 لبناء إصدار الإنتاج:
    echo build.bat release
)

pause
