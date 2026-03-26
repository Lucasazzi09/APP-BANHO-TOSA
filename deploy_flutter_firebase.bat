@echo off
echo ================================
echo Flutter Web Build + Firebase Deploy
echo ================================

echo.
echo [1/5] Limpando projeto...
flutter clean

echo.
echo [2/5] Instalando dependencias...
flutter pub get

echo.
echo [3/5] Buildando projeto (release)...
flutter build web --release

echo.
echo [4/5] Enviando para o Firebase...
firebase deploy

echo.
echo [5/5] Finalizado!
pause
