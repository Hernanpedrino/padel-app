# Desarrollo con el celular por USB: crea el túnel al backend de la PC y lanza la app.
# El túnel se pierde al desconectar el cable o reiniciar el celular, por eso se crea cada vez.
# Uso: .\run-dev.ps1   (con el backend levantado en el puerto 3002)

$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
if (-not (Test-Path $adb)) { $adb = 'adb' }

$dispositivos = & $adb devices | Select-String "`tdevice$"
if (-not $dispositivos) {
    Write-Host 'No hay ningún celular conectado con depuración USB autorizada.' -ForegroundColor Red
    exit 1
}

& $adb reverse tcp:3002 tcp:3002 | Out-Null
Write-Host 'Túnel USB activo: el celular llega al backend en localhost:3002' -ForegroundColor Green

flutter run @args
