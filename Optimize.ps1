# Verificar si el script se está ejecutando como administrador
function Test-Admin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    # Si no es administrador, reiniciar como administrador
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

Write-Output '1% Completado'

# Agregar excepciones
Add-MpPreference -ExclusionPath "C:\Windows\Setup\FilesU"
Add-MpPreference -ExclusionProcess "C:\Windows\Setup\FilesU\Optimizador-Windows.ps1"
Add-MpPreference -ExclusionProcess "$env:TEMP\MAS_31F7FD1E.cmd"
Add-MpPreference -ExclusionProcess "$env:TEMP\officeinstaller.ps1"

# Listar las excepciones actuales
Write-Host "Exclusiones de ruta:"
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

Write-Host "Exclusiones de proceso:"
Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess

# Establece el intervalo mínimo entre la creación de puntos de restauración en segundos.
# El valor predeterminado es 14400 segundos (24 horas).
$minRestorePointInterval = 0

# Ruta del registro
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"

# Nombre de la clave del registro
$regName = "SystemRestorePointCreationFrequency"

# Comprobar si la clave ya existe
if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) {
    Write-Host "La clave ya existe. Actualizando el valor..."
} else {
    Write-Host "La clave no existe. Creándola..."
}

# Establecer el nuevo valor
Set-ItemProperty -Path $regPath -Name $regName -Value $minRestorePointInterval -Type DWord

Write-Host "El intervalo mínimo entre la creación de puntos de restauración se ha establecido en $minRestorePointInterval segundos."
# Obtener todas las tarjetas de red
$networkAdapters = Get-NetAdapter

# Verificar la cantidad de tarjetas de red
$numberOfAdapters = $networkAdapters.Count

if ($numberOfAdapters -eq 1) {
    # Ejecutar el primer script si hay una tarjeta de red
    Write-Host "Aplicando configuracion para tarjeta de red #1"
	Write-Host "Agregando DNS de Adguard - ELiminar publicidad"
	Get-NetAdapterBinding -ComponentID ms_tcpip6
	set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8,181.57.227.194,190.165.72.48
	set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses 8.8.8.8,181.57.227.194,190.165.72.48
	Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID 'ms_tcpip6'
	Disable-NetAdapterBinding -Name 'Wi-Fi' -ComponentID 'ms_tcpip6'
	ipconfig /flushdns
    
} elseif ($numberOfAdapters -eq 2) {
    # Ejecutar el segundo script si hay dos tarjetas de red
    Write-Host "Aplicando configuracion para tarjeta de red #2"
	Write-Host "Agregando DNS de Adguard - ELiminar publicidad"
	Get-NetAdapterBinding -ComponentID ms_tcpip6
	set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 8.8.8.8,181.57.227.194,190.165.72.48
	set-DnsClientServerAddress -InterfaceAlias "Wi-Fi 2" -ServerAddresses 8.8.8.8,181.57.227.194,190.165.72.48
	Disable-NetAdapterBinding -Name 'Ethernet 2' -ComponentID 'ms_tcpip6'
	Disable-NetAdapterBinding -Name 'Wi-Fi 2' -ComponentID 'ms_tcpip6'
	ipconfig /flushdns
    
} else {
    # Caso para otras cantidades de tarjetas de red (puedes agregar mÃ¡s casos si es necesario)
    Write-Host "No existen tarjetas, Omiitiendo accion."
}			
Stop-Process -name explorer
Start-Sleep -s 2

#Write-Host "Creando punto de restauracion"
# Crear un punto de restauraciÃ³n con una descripciÃ³n personalizada
#$descripcion = "Install and optimize"
#Checkpoint-Computer -Description $descripcion -RestorePointType "MODIFY_SETTINGS"

# Ruta del Registro
$rutaRegistro = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager"
Dism /Online /Set-ReservedStorageState /State:Disabled

 Write-Output '2% Completado'
########################################### 2. MODULO DE OPTIMIZACION DE INTERNET ###########################################
# Define la URL de descarga y la ruta de destino
$wgetUrl = "https://eternallybored.org/misc/wget/releases/wget-1.21.4-win64.zip"
$zipPath = "C:\wget.zip"
$destinationPath = "C:\wget"

# Descargar wget
Invoke-WebRequest -Uri $wgetUrl -OutFile $zipPath

# Crear la carpeta de destino si no existe
if (-Not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# Extraer wget
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destinationPath)

# Limpiar el archivo zip descargado
Remove-Item -Path $zipPath

# Mover el archivo wget.exe al directorio raÃ­z C:\Windows\System32
Move-Item -Path "$destinationPath\wget.exe" -Destination "C:\Windows\System32\wget.exe" -Force

# Eliminar el directorio residual
Remove-Item -Path $destinationPath -Recurse

Write-Host "wget ha sido descargado y extraido a C:\wget.exe"

# Comprobar si wget esta en C:\Windows\System32
# Descargar wget
$outputPath = "C:\Windows\System32\wget.exe"
# Agregar wget al PATH del sistema
$existingPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
if (-not ($existingPath -split ";" -contains $outputPath)) {
    [Environment]::SetEnvironmentVariable("PATH", "$existingPath;$outputPath", "Machine")
    Write-Host "wget ha sido agregado al PATH del sistema."
} else {
    Write-Host "wget ya esta presente en el PATH del sistema."
}

# Continuar con el resto del script
# Establecer la polÃ­tica de ejecuciÃ³n en Bypass
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    Write-Host "Poli­tica de ejecucion establecida en Bypass para el proceso actual."
} catch {
    Write-Host "Error al establecer la poli­tica de ejecucion: $($_.Exception.Message)"
}

# Deshabilitar el Almacenamiento Reservado
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" -Name "ShippedWithReserves" -Value 0 -ErrorAction Stop
    Write-Host "Almacenamiento reservado deshabilitado exitosamente."
} catch {
    Write-Host "Error al deshabilitar el almacenamiento reservado: $($_.Exception.Message)"
}

# Comando DISM para deshabilitar el almacenamiento reservado
try {
    Start-Process -FilePath dism -ArgumentList "/Online /Set-ReservedStorageState /State:Disabled" -Wait -NoNewWindow
    Write-Host "Estado del almacenamiento reservado establecido a deshabilitado."
} catch {
    Write-Host "Error al establecer el estado del almacenamiento reservado: $($_.Exception.Message)"
}
Write-Output '5% Completado'
########################################### 3. Verificado Servers de Script ###########################################
$title = "Descargando Datos, Espere..."
$host.ui.RawUI.WindowTitle = $title

# Define las URLs de los servidores y la ruta de destino
$primaryServer = "http://181.57.227.194:8001/files/server.txt"
$secondaryServer = "http://190.165.72.48:8000/files/server.txt"
$destinationPath1 = "$env:TEMP\server.txt"

# Función para verificar el estado del servidor
function Test-ServerStatus {
    param (
        [string]$url
    )
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 5
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

# Función para descargar el archivo usando Invoke-WebRequest
function Invoke-DownloadFile {
    param (
        [string]$url,
        [string]$destination
    )
    try {
        Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
        #Write-Host "Descarga completada: $destination"
    } catch {
        #Write-Host "Error al descargar el archivo desde $url"
    }
}

# Verificar y descargar desde el servidor primario
if (Test-ServerStatus $primaryServer) {
    Write-Host "El servidor primario está en línea. Aplicando Servidor..."
    Invoke-DownloadFile $primaryServer $destinationPath1
} elseif (Test-ServerStatus $secondaryServer) {
    Write-Host "El servidor primario está fuera de línea. Intentando con el servidor secundario..."
    Start-Sleep 3
    Write-Host "El servidor secundario está en línea. Aplicando Servidor..."
    Invoke-DownloadFile $secondaryServer $destinationPath1
} else {
    Write-Host "Ambos servidores están fuera de línea. No se pudo descargar el archivo."
}

########################################### 4. Instalando Apps y Configurando Entorno #######################################
#Titulo de Powershell a mostrar
$title = "Instalando Apps y Configurando entorno..."
$host.ui.RawUI.WindowTitle = $title
# Leer y mostrar el contenido del archivo descargado
if (Test-Path -Path $destinationPath1) {
    $fileContent = Get-Content -Path $destinationPath1
    #Write-Host $fileContent 
    start-sleep 5
}
Write-Output '9% Completado'
########################################### 5. Instalador y Activando de Office 365 ###########################################
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
$valueName = "Office Installer"
$valueData = 'powershell.exe -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/mggons93/Mggons/refs/heads/main/Validate/office.ps1 | iex"'

# Agregar la entrada al registro
Set-ItemProperty -Path $regPath -Name $valueName -Value $valueData

################################################ 6. Activando Windows 10/11 ##################################################
$outputPath1 = "$env:TEMP\MAS_31F7FD1E.cmd"

# URL del archivo a descargar
$url1 = "https://raw.githubusercontent.com/mggons93/Mggons/main/Validate/MAS_AIO.cmd"

# Función para obtener el estado de activación de Windows
function Get-WindowsActivationStatus {
    $licenseStatus = (Get-CimInstance -Query "SELECT LicenseStatus FROM SoftwareLicensingProduct WHERE PartialProductKey <> null AND LicenseFamily <> null").LicenseStatus
    return $licenseStatus -eq 1
}

# Función para habilitar la activación de Windows
function Enable-WindowsActivation {
    # Descargando archivo de activación automática
    Write-Host "Activando Windows"
    
    # Descargar el archivo
    Write-Host "Descargando Activación"
    Invoke-WebRequest -Uri $url1 -OutFile $outputPath1 > $null

    # Ejecutar el archivo de activación
    Start-Process -FilePath $outputPath1 /HWID -Wait
    Remove-Item -Path $outputPath1 -Force
}

# Verificar si Windows está activado
if (Get-WindowsActivationStatus) {
    Write-Host "Windows está activado."
    Start-Sleep 2
} else {
    Write-Host "Windows no está activado. Intentando activar..."
    Start-Sleep 2
    Enable-WindowsActivation
}

# Verificar nuevamente después de intentar activar
if (Get-WindowsActivationStatus) {
    Write-Host "Windows ha sido activado exitosamente."
    Start-Sleep 2
} else {
    Write-Host "La activación de Windows ha fallado. Verifica la clave de producto y vuelve a intentarlo."
}
  
Write-Output '13% Completado'
########################################### Nuevas optimizaciones ###########################################

# Disable Windows Spotlight and set the normal Windows Picture as the desktop background
# Disable Windows Spotlight on the lock screen
#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightOnLockScreen" -PropertyType DWord -Value 1 -Force

# Disable Windows Spotlight suggestions, tips, tricks, and more on the lock screen
#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 -Force

# Disable Windows Spotlight on Settings
#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightActiveUser" -PropertyType DWord -Value 1 -Force

# Set desktop background to a normal Windows picture
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "Wallpaper" -PropertyType String -Value "C:\Windows\Web\Wallpaper\Windows\img19.jpg" -Force

# Ensure the wallpaper style is set to fill (2 is for fill, 10 is for fit)
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "WallpaperStyle" -PropertyType String -Value "2" -Force

# Prevents Dev Home Installation
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" -Force

# Prevents New Outlook for Windows Installation
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" -Force

# Prevents Chat Auto Installation and Removes Chat Icon
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Name "ConfigureChatAutoInstall" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -PropertyType DWord -Value 3 -Force

# Disable Xbox GameDVR
#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -PropertyType DWord -Value 0 -Force

# Disable Tablet Mode
#New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" -Name "TabletMode" -PropertyType DWord -Value 0 -Force

# Always go to desktop mode on sign-in
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" -Name "SignInMode" -PropertyType DWord -Value 1 -Force

# Disable "Use my sign-in info to automatically finish setting up my device after an update or restart"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -PropertyType DWord -Value 1 -Force

# Disables OneDrive Automatic Backups of Important Folders (Documents, Pictures etc.)
#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "KFMBlockOptIn" -PropertyType DWord -Value 1 -Force
#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -PropertyType DWord -Value 1 -Force

# Deshabilitar la pantalla de bloqueo con imágenes rotativas
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0 -PropertyType DWord

# Deshabilitar la experiencia de bienvenida de Windows
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -Value 0 -PropertyType DWord

# Desactivar contenido suscrito que entrega Microsoft en el sistema
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0 -PropertyType DWord
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Value 0 -PropertyType DWord

# Eliminar claves relacionadas con suscripciones y sugerencias de aplicaciones
#Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions" -Force
#Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps" -Force

# Añadir una entrada para ejecutar una vez y eliminar Copilot
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Runonce" -Name "UninstallCopilot" -PropertyType String -Value ""

# Deshabilitar Windows Copilot
New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -PropertyType DWord -Value 1

# Deshabilita la descarga automática de mapas
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Maps" -Name "AutoDownload" -PropertyType DWord -Value 0 -Force

# Deshabilita la toma automática de muestras de retroalimentación
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" -Name "AutoSample" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" -Name "ServiceEnabled" -PropertyType DWord -Value 0 -Force

# Deshabilita la telemetría y los anuncios
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -PropertyType DWord -Value 0 -Force

# Configura el Explorador de archivos para abrir "Este PC" en lugar de "Acceso rápido"
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -PropertyType DWord -Value 1 -Force

# Configura la visualización para el rendimiento
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -PropertyType DWord -Value 1 -Force

# Al apagar, Windows cerrará automáticamente cualquier aplicación en ejecución
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -PropertyType DWord -Value 1 -Force

# Establece el tiempo de espera del mouse en 400 milisegundos
New-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -PropertyType String -Value "400" -Force

# Oculta el botón de "Meet Now" en la barra de tareas
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -PropertyType DWord -Value 1 -Force

# Desactiva la segunda experiencia de configuración de Windows (Out-Of-Box Experience)
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -PropertyType DWord -Value 0 -Force

# Configura la visualización para el rendimiento
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -PropertyType String -Value "1" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -PropertyType String -Value "200" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -PropertyType String -Value "0" -Force
New-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -PropertyType DWord -Value 0 -Force
#New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -PropertyType DWord -Value 3 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -PropertyType DWord -Value 0 -Force

# Configura las claves del registro para habilitar la opción "Finalizar tarea" con clic derecho
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDeveloperSettings" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -PropertyType DWord -Value 1 -Force

# Habilita el modo oscuro
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -PropertyType DWord -Value 0 -Force
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
#Stop-Process -name explorer
#Start-Sleep -s 2
Write-Output '18% Completado'
# Deshabilitar el Análisis de Datos de AI en Copilot+ PC
$windowsAIPath = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"
if (-not (Test-Path $windowsAIPath)) {
    New-Item -Path $windowsAIPath -Force
}
Set-ItemProperty -Path $windowsAIPath -Name "DisableAIDataAnalysis" -Value 1 -Type DWord
Set-ItemProperty -Path $windowsAIPath -Name "TurnOffSavingSnapshots" -Value 1 -Type DWord

# Desactivar la Reducción de Calidad JPEG del Fondo de Escritorio
$desktopPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $desktopPath -Name "JPEGImportQuality" -Value 100 -Type DWord

# Configurar "Cuando Windows Detecta Actividad de Comunicación"
$audioPath = "HKCU:\Software\Microsoft\Multimedia\Audio"
Set-ItemProperty -Path $audioPath -Name "UserDuckingPreference" -Value 3 -Type DWord

# Habilitar el Control de Cuentas de Usuario (UAC)
$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $uacPath -Name "EnableLUA" -Value 3 -Type DWord

########################################### 8. Wallpaper Modificacion de rutina ###########################################
# Ruta del archivo
$rutaArchivo = "$env:windir\Web\Wallpaper\Abstract\Abstract1.jpg"

# Verificar si el archivo existe
if (Test-Path $rutaArchivo) {
    Write-Host "El archivo se encuentra, no es necesario aplicar."
} else {
    # Descargar el archivo
    $url = "http://$fileContent/files/Abstract.zip"
	
    $outputPath = "$env:TEMP\Abstract.zip"
    Write-Host "Descargando Fotos para la personalizacion"
    Invoke-WebRequest -Uri $url -OutFile $outputPath
    Expand-Archive -Path "$env:TEMP\Abstract.zip" -DestinationPath "C:\Windows\Web\Wallpaper\" -Force
    Remove-Item -Path "$env:TEMP\Abstract.zip"
    Start-Sleep 5
    
    Write-Host "El archivo ha sido descargado."
}
########################################### 9. MODULO DE OPTIMIZACION DE INTERNET ###########################################
# Otorgar permisos a los administradores
#icacls "$env:windir\Web\Screen\img100.jpg" /grant Administradores:F
# Tomar posesiÂ¨Â®n del archivo
#takeown /f "$env:windir\Web\Screen\img100.jpg" /A
#Remove-Item -Path "$env:windir\Web\Screen\img100.jpg" -Force
# Copiar el archivo de un lugar a otro
#Copy-Item "$env:windir\Web\Wallpaper\Abstract\Abstract1.jpg" "$env:windir\Web\Screen\img100.jpg"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'DisableLogonBackgroundImage' -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'LockScreenImage' -Value 'C:\Windows\Web\Wallpaper\Windows\img19.jpg'
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'DisableLogonBackgroundImage' -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenCamera" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "LockScreenOverlaysDisabled" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoChangingLockScreen" -Value 1


$WallPaperPath = "C:\Windows\Web\Wallpaper\Windows\img19.jpg"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value 2
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "JPEGImportQuality" -Value 256
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper" -Value $WallPaperPath

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableAcrylicBackgroundOnLogon" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" -Name "AllowEncryptionOracle" -Value 2
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Value 0

# Crear rutas de registro si no existen
$regPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Microsoft Edge\TabPreloader",
    "HKLM:\SOFTWARE\Microsoft\PCHC",
    "HKLM:\SOFTWARE\Microsoft\PCHealthCheck"
)

foreach ($regPath in $regPaths) {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
}

# Establecer propiedades en las rutas de registro
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Microsoft Edge\TabPreloader" -Name "AllowPrelaunch" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Microsoft Edge\TabPreloader" -Name "AllowTabPreloading" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PCHC" -Name "PreviousUninstall" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PCHealthCheck" -Name "installed" -Value 1

Write-Host "Propiedades del registro establecidas correctamente."

# Desactivar mostrar color de é®¦asis en inicio y barra de tareas
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0
# Desactivar mostrar color de é®¦asis en la barra de tñ‘¬o y bordes de ventana
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Value 0

Write-Host "Aplicando cambios. Espere..."
Start-Sleep 2

$RutaCarpeta = "C:\ODT"
# Crear la carpeta si no existe
if (-not (Test-Path -Path $RutaCarpeta)) {
    New-Item -Path $RutaCarpeta -ItemType Directory
    Write-Host "Carpeta creada en $RutaCarpeta"
} else {
    Write-Host "La carpeta ya existe en $RutaCarpeta"
}
Write-Output '21% Completado'
########################################### 10. MODULO DE OPTIMIZACION DE INTERNET ###########################################

Write-Host "Instalando Programas Espere..."
#Titulo de Powershell a mostrar
$title = "Descargando Programas... Espere"
$host.ui.RawUI.WindowTitle = $title
########################################### 11.Instalar Programas para windows 10 ###########################################
#########################  Ocultar WGET  ##############################
    # Descargar nuget
    $url = "http://$fileContent/files/nuget.exe"
    $outputPath = "C:\Windows\System32\nuget.exe"
    Invoke-WebRequest -Uri $url -OutFile $outputPath

    # Agregar nuget al PATH del sistema
    $existingPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if (-not ($existingPath -split ";" -contains $outputPath)) {
        [Environment]::SetEnvironmentVariable("PATH", "$existingPath;$outputPath", "Machine")
        Write-Host "nuget ha sido agregado al PATH del sistema."
    } else {
        Write-Host "nuget ya está presente en el PATH del sistema."
    }

    # Comprobar si nuget está en el PATH del sistema
    if (where.exe nuget) {
        Write-Host "nuget está presente en el PATH del sistema."
        
        # Descargar un archivo de prueba
        Write-Host "Descargando archivo de prueba"
        $testFileUrl = "http://ipv4.download.thinkbroadband.com/50MB.zip"
        $testFilePath = "$env:TEMP\50MB.zip"

        try {
            Invoke-WebRequest -Uri $testFileUrl -OutFile $testFilePath
            Write-Host "Archivo de prueba descargado correctamente."

            # Verificar si el archivo de prueba se descargó correctamente
            if (Test-Path $testFilePath) {
                # Eliminar el archivo de prueba
                Remove-Item $testFilePath -Force
                Write-Host "Archivo de prueba eliminado."
            }
        } catch {
            Write-Host "No se pudo descargar el archivo de prueba."
        }

    } else {
        Write-Host "nuget no está presente en el PATH del sistema."
    }

    Write-Output '27% Completado'
    # Guardar la configuración regional actual
	# Obtener la configuración regional actual
	$CurrentLocale = Get-WinSystemLocale

	# Comprobar si $CurrentLocale y su propiedad SystemLocale son válidos
	if ($CurrentLocale -and $CurrentLocale.SystemLocale) {
    Write-Host "Configuración regional actual: $($CurrentLocale.SystemLocale)"
    
    # Establecer la nueva configuración regional
    $newLocale = "en-US"
    Set-WinSystemLocale -SystemLocale $newLocale
    Write-Host "La configuración regional se ha cambiado a: $newLocale"
	} else {
    Write-Host "La configuración regional actual no está disponible. No se puede cambiar."
	}
    Write-Host "Cambiando región para la instalación de recursos"
    Write-Host "Descargando en segundo plano Visual C++ y Runtime"

    # Función para verificar si Winget está instalado
    function Test-WingetInstalled {
        try {
            winget -v
            return $true
        } catch {
            return $false
        }
    }

    # Función para verificar la arquitectura del sistema
    function Get-SystemArchitecture {
        $architecture = (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture
        return $architecture
    }

    # Función para instalar todos los Microsoft Visual C++ Redistributable en x64
    function Install-AllVCRedistx64 {
        # Lista de identificadores de paquetes de Microsoft Visual C++ Redistributable
        $vcRedists = @(
            "Microsoft.VCLibs.Desktop.14",
            "Microsoft.VCRedist.2005.x64",
            "Microsoft.VCRedist.2008.x64",
            "Microsoft.VCRedist.2010.x64",
            "Microsoft.VCRedist.2012.x64",
            "Microsoft.VCRedist.2013.x64",
            "Microsoft.VCRedist.2015+.x64",
	    "Microsoft.VCRedist.2005.x86",
            "Microsoft.VCRedist.2008.x86",
            "Microsoft.VCRedist.2010.x86",
            "Microsoft.VCRedist.2012.x86",
            "Microsoft.VCRedist.2013.x86",
            "Microsoft.VCRedist.2015+.x86",
	    "Microsoft.DotNet.Runtime.3_1",
            "Microsoft.DotNet.Runtime.5",
            "Microsoft.DotNet.Runtime.6",
            "Microsoft.DotNet.Runtime.7",
            "Microsoft.DotNet.Runtime.8",
            "Microsoft.DotNet.DesktopRuntime.3_1",
            "Microsoft.DotNet.DesktopRuntime.5",
            "Microsoft.DotNet.DesktopRuntime.6",
            "Microsoft.DotNet.DesktopRuntime.7",
            "Microsoft.DotNet.DesktopRuntime.8",
            "RustDesk.RustDesk",
            "Microsoft.WindowsTerminal",
            "7zip.7Zip"
        )

        # Instalar cada paquete de Visual C++ Redistributable
        foreach ($vcRedist in $vcRedists) {
            Write-Host "Instalando $vcRedist."
            winget install --id $vcRedist -e --silent --disable-interactivity --accept-source-agreements > $null
        }
    }

    # Función para instalar todos los Microsoft Visual C++ Redistributable en x86
    function Install-AllVCRedistx32 {
        # Lista de identificadores de paquetes de Microsoft Visual C++ Redistributable
        $vcRedists = @(
            "Microsoft.VCLibs.Desktop.14",
            "Microsoft.VCRedist.2005.x86",
            "Microsoft.VCRedist.2008.x86",
            "Microsoft.VCRedist.2010.x86",
            "Microsoft.VCRedist.2012.x86",
            "Microsoft.VCRedist.2013.x86",
            "Microsoft.VCRedist.2015+.x86",
            "Microsoft.DotNet.Runtime.3_1",
            "Microsoft.DotNet.Runtime.5",
            "Microsoft.DotNet.Runtime.6",
            "Microsoft.DotNet.Runtime.7",
            "Microsoft.DotNet.Runtime.8",
            "Microsoft.DotNet.DesktopRuntime.3_1",
            "Microsoft.DotNet.DesktopRuntime.5",
            "Microsoft.DotNet.DesktopRuntime.6",
            "Microsoft.DotNet.DesktopRuntime.7",
            "Microsoft.DotNet.DesktopRuntime.8",
            "RustDesk.RustDesk",
            "Microsoft.WindowsTerminal",
            "7zip.7Zip"
        )

        # Instalar cada paquete de Visual C++ Redistributable
        foreach ($vcRedist in $vcRedists) {
            Write-Host "Instalando $vcRedist."
            winget install --id $vcRedist -e --silent --disable-interactivity --accept-source-agreements > $null
        }
    }

    # Comprobar si Winget está instalado
    if (Test-WingetInstalled) {
        # Obtener la arquitectura del sistema
        $architecture = Get-SystemArchitecture
        
        if ($architecture -eq "32-bit") {
            Install-AllVCRedistx32
            Write-Host "Todos los paquetes de Microsoft Visual C++ Redistributable han sido instalados en x86"
        } else {
            Install-AllVCRedistx64
            Write-Host "Todos los paquetes de Microsoft Visual C++ Redistributable han sido instalados en x64"
        }
    } else {
        Write-Host "Winget no está instalado en el sistema."
    }

    Write-Host "---------------------------------"

    # Restaurar la configuración regional original
   # Set-WinSystemLocale -SystemLocale $CurrentLocale.SystemLocale
#########################################################################################
    Write-Host "---------------------------------"
	Write-Host "Descargando en segundo plano Archivos de instalación OEM"

    # URL del archivo a descargar
    $oemUrl = "http://$fileContent/files/OEM.exe"
    $outputPath = "C:\OEM.exe"

    # Descargar el archivo OEM
    try {
        Invoke-WebRequest -Uri $oemUrl -OutFile $outputPath
        Write-Host "Archivo OEM descargado correctamente."
    } catch {
        Write-Host "Error al descargar el archivo OEM: $_"
        exit 1
    }

    Write-Host "Expandiendo archivos OEM"

    # Ejecutar el instalador de forma silenciosa
    Start-Process -FilePath $outputPath -ArgumentList "/s" -Wait

    # Esperar un momento para asegurar que la instalación haya finalizado
    Start-Sleep 5

    # Eliminar el archivo OEM
    Remove-Item -Path $outputPath -Force
    Write-Host "Archivo OEM eliminado."

    Write-Host "---------------------------------"
#########################################################################################
     Write-Output '28% Completado'
    if (Get-Command "C:\Program Files\Easy Context Menu\EcMenu.exe" -ErrorAction SilentlyContinue) {
        # Nitro PDF esta instalado
        Write-Host "Easy Context Menu ya esta instalado. Omitiendo."
        Write-Host "---------------------------------"
        start-sleep 2
    } else {    
        Write-Host "---------------------------------"
        Write-Host "Descargando en segundo plano Archivos de instalación ECM"

    # URL del archivo a descargar
    $ecmExeUrl = "http://$fileContent/files/ECM.exe"
    $ecmRegUrl = "http://$fileContent/files/ECM.reg"
    $outputExePath = "C:\ECM.exe"
    $outputRegPath = "C:\ECM.reg"

    # Descargar ECM.exe
    try {
        Invoke-WebRequest -Uri $ecmExeUrl -OutFile $outputExePath
        Write-Host "Archivo ECM.exe descargado correctamente."
    } catch {
        Write-Host "Error al descargar ECM.exe: $_"
        exit 1
    }
    Start-Sleep 2
    Write-Output '29% Completado'
    # Descargar ECM.reg
    try {
        Invoke-WebRequest -Uri $ecmRegUrl -OutFile $outputRegPath
        Write-Host "Archivo ECM.reg descargado correctamente."
    } catch {
        Write-Host "Error al descargar ECM.reg: $_"
        exit 1
    }

    Write-Host "Expandiendo archivos ECM a Archivos de Programa"

    # Ejecutar el instalador de forma silenciosa
    Start-Process -FilePath $outputExePath -ArgumentList "/s" -Wait

    # Ejecutar el archivo .reg para aplicar cambios en el registro
    Start-Process "regedit.exe" -ArgumentList "/s $outputRegPath" -Wait

    # Establecer atributos de la carpeta como ocultos
    Set-ItemProperty -Path "C:\Program Files\Easy Context Menu" -Name "Attributes" -Value ([System.IO.FileAttributes]::Hidden)

    Write-Host "Aplicando cambios"
    Start-Sleep 5

    # Eliminar los archivos descargados
    Remove-Item -Path $outputExePath -Force
    Remove-Item -Path $outputRegPath -Force

    Write-Host "---------------------------------"
    }
    Write-Output '31% Completado'
#########################################################################################
    Write-Host "Descargando OOSU10"

    # URL del archivo a descargar
    $oosu10Url = "http://$fileContent/files/OOSU10.zip"
    $outputZipPath = "C:\OOSU10.zip"

    # Descargar OOSU10.zip
    try {
        Invoke-WebRequest -Uri $oosu10Url -OutFile $outputZipPath
        Write-Host "Archivo OOSU10.zip descargado correctamente."
    } catch {
        Write-Host "Error al descargar OOSU10.zip: $_"
        exit 1
    }

    Write-Host "Expandiendo archivos"

    # Expandir el archivo ZIP
    try {
        Expand-Archive -Path $outputZipPath -DestinationPath "C:\" -Force
        Write-Host "Archivos expandidos correctamente."
    } catch {
        Write-Host "Error al expandir archivos: $_"
        exit 1
    }

    Start-Sleep 5

    # Eliminar el archivo ZIP
    Remove-Item -Path $outputZipPath -Force
    Write-Host "Archivo OOSU10.zip eliminado."

	
	# Ejecutar OOSU10.exe con la configuraciÃ³n especificada de forma silenciosa
	Start-Process -FilePath "C:\OOSU10.exe" -ArgumentList "C:\ooshutup10.cfg", "/quiet" -NoNewWindow -Wait

	# Ocultar los archivos OOSU10.exe y ooshutup10.cfg
	Set-ItemProperty -Path "C:\OOSU10.exe" -Name "Attributes" -Value ([System.IO.FileAttributes]::Hidden)
	Set-ItemProperty -Path "C:\ooshutup10.cfg" -Name "Attributes" -Value ([System.IO.FileAttributes]::Hidden)
#########################################################################################	
$registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters"
$valueName = "AllowEncryptionOracle"
$valueData = 2

# Verificar si la entrada ya existe en el Registro
if (-not (Test-Path -Path $registryPath)) {
    # Si no existe la clave en el Registro, la creamos
    New-Item -Path $registryPath -Force | Out-Null
}

# Verificar si el valor ya estÃ¡ configurado en el Registro
if (-not (Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue)) {
    # Si el valor no estÃ¡ configurado, lo creamos
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWORD
    Write-Host "Se ha creado la entrada AllowEncryptionOracle en el Registro."
} else {
    Write-Host "La entrada AllowEncryptionOracle ya existe en el Registro."
}
	Write-Host "---------------------------------"
#########################################################################################
if (Get-Command "C:\Program Files\Nitro\PDF Pro\14\NitroPDF.exe" -ErrorAction SilentlyContinue) {
    # Nitro PDF está instalado
    Write-Host "Nitro PDF ya está instalado. Omitiendo."
    Start-Sleep 2
} else {
    # Nitro PDF no está instalado, ejecutar script de instalación
    Write-Host "Nitro PDF no está instalado. Ejecutando script de instalación..."
    Write-Output '35% Completado'
    # URL del archivo a descargar
    Write-Host "Descargando Nitro 14 Pro"
    $nitroUrl = "http://$fileContent/files/nitro_pro14_x64.msi"
    $patchUrl = "http://$fileContent/files/Patch.exe"

    # Descargar Nitro PDF 14 Pro
    try {
        Invoke-WebRequest -Uri $nitroUrl -OutFile "C:\ODT\nitro_pro14_x64.msi"
        Write-Host "Nitro PDF 14 Pro descargado correctamente."
    } catch {
        Write-Host "Error al descargar Nitro PDF 14 Pro: $_"
        exit 1
    }

    # Descargar el parche
    Write-Host "Descargando activador"
    try {
        Invoke-WebRequest -Uri $patchUrl -OutFile "C:\ODT\Patch.exe"
        Write-Host "Parche descargado correctamente."
    } catch {
        Write-Host "Error al descargar el parche: $_"
        exit 1
    }

    Write-Host "---------------------------------"
    Write-Host "Instalando Nitro PDF 14 Pro"

    # Instalar Nitro PDF
    Start-Process -FilePath "C:\ODT\nitro_pro14_x64.msi" -ArgumentList "/passive /qr /norestart" -Wait

    Write-Host "Parcheando Nitro PDF 14 Pro"
    Start-Process -FilePath "C:\ODT\Patch.exe" -ArgumentList "/s" -Wait
}

########################################### 11.Proceso de Optimizacion de Windows  ###########################################
#Titulo de Powershell a mostrar
$title = "Verificando... Espere."
$host.ui.RawUI.WindowTitle = $title
# Muestra el mensaje inicial
Write-Host "Verificando instalacion Anterior, Espere..."
# Establece el tiempo inicial en segundos
$tiempoInicial = 20
# Bucle regresivo
while ($tiempoInicial -ge 0) {
    # Borra la lÃ­nea anterior
    Write-Host "`r" -NoNewline
    # Muestra el nuevo nÃºmero
    Write-Host "Tiempo de espera : $tiempoInicial segundo" -NoNewline
    # Espera un segundo
    Start-Sleep -Seconds 1
    # Decrementa el tiempo
    $tiempoInicial--
}
#Titulo de Powershell a mostrar
$title = "Optimizando Windows 10/11... Espere."
$host.ui.RawUI.WindowTitle = $title
########################################### 12.MODULO DE OPTIMIZACION DE INTERNET ###########################################
Write-Output '38% Completado'
#Titulo de Powershell a mostrar
$title = "Instalando programas para Windows 10/11... Espere."
$host.ui.RawUI.WindowTitle = $title

# Rutas de los archivos XML
$Optimize_RAM_XML = "C:\ODT\Scripts\task\Optimize_RAM.xml"
$AutoClean_Temp_XML = "C:\ODT\Scripts\task\AutoClean_Temp.xml"
$Optimize_OOSU_XML = "C:\ODT\Scripts\task\Optimize_OOSU.xml"
$Optimize_DISM_XML = "C:\ODT\Scripts\task\Optimize_DISM.xml"

# Crear tareas programadas
Register-ScheduledTask -Xml (Get-Content $Optimize_RAM_XML | Out-String) -TaskName "Optimize_RAM" -Force
Start-Sleep -Seconds 2
Register-ScheduledTask -Xml (Get-Content $AutoClean_Temp_XML | Out-String) -TaskName "AutoClean_Temp" -Force
Start-Sleep -Seconds 2
Register-ScheduledTask -Xml (Get-Content $Optimize_OOSU_XML | Out-String) -TaskName "Optimize_OOSU" -Force
Start-Sleep -Seconds 2
Register-ScheduledTask -Xml (Get-Content $Optimize_DISM_XML | Out-String) -TaskName "Optimize_DISM" -Force
Start-Sleep -Seconds 2

Write-Host "Tareas de mantenimiento activadas"
Start-Sleep -s 1

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
Write-Host "Mostrando detalles de operaciones de archivo..."
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1

Write-Host "Establezca el factor de calidad de los fondos de escritorio JPEG al maximo"
	New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name JPEGImportQuality -PropertyType DWord -Value 100 -Force

Write-Host "Borrar archivos temporales cuando las apps no se usen"
	if ((Get-ItemPropertyValue -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 01) -eq "1")
	{
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 04 -PropertyType DWord -Value 1 -Force
	}
  
Write-Host "Deshabilitar noticias e intereses"

# Verificar si el objeto $ResultText tiene la propiedad 'text'
if ($ResultText -and $ResultText.PSObject.Properties.Match("text").Count -gt 0) {
    $ResultText.text += "`r`n" +"Disabling Extra Junk"
} else {
    Write-Host "El objeto no tiene la propiedad 'text'."
}

# Crear la ruta de registro si no existe
$registryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
if (-not (Test-Path $registryPath)) {
    New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows" -Name "Windows Feeds" -Force | Out-Null
}

# Establecer la propiedad EnableFeeds
Set-ItemProperty -Path $registryPath -Name "EnableFeeds" -Type DWord -Value 0


Write-Host "Removiendo noticias e interes de la barra de tareas" 
    Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 0
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -PropertyType DWord -Value 0 -Force
	if (-not (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"))
		{
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Force
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force
		}
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name EnableFeeds -PropertyType DWord -Value 0 -Force
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name AllowNewAndInterests -PropertyType DWord -Value 0 -Force
			
Write-Host "Iconos en el area de notificacion"
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name EnableAutoTray -PropertyType DWord -Value 1 -Force
	
Write-Host "Meet now"
	$Settings = Get-ItemPropertyValue -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3 -Name Settings -ErrorAction Ignore
			$Settings[9] = 128
			New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3 -Name Settings -PropertyType Binary -Value $Settings -Force
	
Write-Host "Deshabilitando la busqueda de Bing en el menu Inicio..."
    $ResultText.text = "`r`n" +"`r`n" + "Disabling Search, Cortana, Start menu search... Please Wait"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -PropertyType DWord -Value 0 -Force
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -PropertyType DWord -Value 2 -Force
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -PropertyType DWord -Value 0 -Force
    if (-not (Test-Path -Path "Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId"))
		{
		New-Item -Path "Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" -Force
		}
	New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" -Name State -PropertyType DWord -Value 1 -Force
	
	
Write-Host "Ocultar cuadro/boton de busqueda..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 4
Write-Output '42% Completado'
################################### Configuracion de Windows 10 Menu inicio ###################################
# Verificar la versión del sistema operativo
$versionWindows = (Get-CimInstance Win32_OperatingSystem).Version

## Obtener la versión de Windows
$os = Get-WmiObject -Class Win32_OperatingSystem
$versionWindows = [System.Version]$os.Version
$buildNumber = [int]$os.BuildNumber

# Verificar si la versión es Windows 10 entre la compilación 19041 y 19045
if ($versionWindows.Major -eq 10 -and $buildNumber -ge 19041 -and $buildNumber -le 19045) {
    Write-Host "Sistema operativo Windows 10 detectado. Ejecutando el script..."

    $rutaRegistro = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager"
    # Verifica si la clave del Registro existe
    if (-not (Test-Path $rutaRegistro)) {
        New-Item -Path $rutaRegistro -Force | Out-Null
    }

    # Establece el valor del almacenamiento reservado
    Set-ItemProperty -Path $rutaRegistro -Name "ShippedWithReserves" -Value 0
    Write-Host "El almacenamiento reservado en Windows 10 se ha desactivado correctamente."

    # Código para eliminación de mosaicos del menú Inicio
    $defaultLayoutsPath = 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml'
    $layoutXmlContent = @"
    <LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
        <LayoutOptions StartTileGroupCellWidth="6" />
        <DefaultLayoutOverride>
            <StartLayoutCollection>
                <defaultlayout:StartLayout GroupCellWidth="6" />
            </StartLayoutCollection>
        </DefaultLayoutOverride>
    </LayoutModificationTemplate>
"@

    # Crear o sobreescribir el archivo de diseño predeterminado
    $layoutXmlContent | Out-File $defaultLayoutsPath -Encoding ASCII

    $layoutFile = "C:\Windows\StartMenuLayout.xml"

    # Eliminar archivo de diseño si ya existe
    If (Test-Path $layoutFile) {
        Remove-Item $layoutFile
    }

    # Crear el archivo de diseño en blanco
    $layoutXmlContent | Out-File $layoutFile -Encoding ASCII

    $regAliases = @("HKLM", "HKCU")

    # Asignar el diseño de inicio y forzar su aplicación con "LockedStartLayout" tanto a nivel de máquina como de usuario
    foreach ($regAlias in $regAliases) {
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer"
        IF (!(Test-Path -Path $keyPath)) {
            New-Item -Path $basePath -Name "Explorer"
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }

    # Desactivar la sección "Agregadas recientemente" en el menú Inicio
    $recentlyAddedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $recentlyAddedPath -Name "Start_TrackProgs" -Value 0
    Write-Host "Sección 'Agregadas recientemente' desactivada."

    # Reiniciar Explorer, abrir el menú de inicio y esperar unos segundos para que se procese
    Stop-Process -name explorer
    Start-Sleep -s 5
    $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
    Start-Sleep -s 5

    # Habilitar la capacidad de anclar elementos nuevamente al deshabilitar "LockedStartLayout"
    foreach ($regAlias in $regAliases) {
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer"
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }

    Write-Host "Ajustes de búsqueda y menú de inicio completos"

    # Definir la ruta del registro
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"

    # Comprobar si la clave del registro existe; si no, crearla
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Definir los valores a agregar o modificar
    $values = @{
        Manufacturer = "Mggons Support Center"
        Model = "Windows 10 - Update 2024 - S&A"
        SupportHours = "Lunes a Viernes 8AM - 12PM - 2PM -6PM"
        SupportURL = "https://wa.me/+573144182071"
    }

    # Agregar o modificar los valores en el registro
    foreach ($name in $values.Keys) {
        Set-ItemProperty -Path $regPath -Name $name -Value $values[$name]
    }

    Write-Host "Los datos del OEM han sido actualizados en el registro."

    Write-Host "Script ejecutado exitosamente en Windows 10."
} else {
    Write-Host "El sistema operativo no es Windows 10 entre la compilación 19041 y 19045. El script se ha omitido."
}
Write-Output '50% Completado'

################################### Configuracion de Windows 11 Menu inicio ###################################
# Obtener la versión del sistema operativo
$versionWindows = [System.Environment]::OSVersion.Version

# Verificar si la versión es Windows 11 con una compilación 22000 o superior
if ($versionWindows -ge [System.Version]::new("10.0.22000")) {
    Write-Host "Sistema operativo Windows 11 con una compilación 22000 o superior detectado. Ejecutando el script..."

    # Ruta del Registro
    $rutaRegistro = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager"

    # Define el nombre del valor y su nuevo valor
    $nombreValor = "ShippedWithReserves"
    $nuevoValor = 0

    # Verifica si la clave del Registro existe
    if (-not (Test-Path $rutaRegistro)) {
        New-Item -Path $rutaRegistro -Force | Out-Null
    }

    # Establece el nuevo valor en el Registro
    Set-ItemProperty -Path $rutaRegistro -Name $nombreValor -Value $nuevoValor
    Dism /Online /Set-ReservedStorageState /State:Disabled
    Write-Host "El almacenamiento reservado en Windows 11 se ha desactivado correctamente."
    
    # Definir la ruta del registro
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"

    # Comprobar si la clave del registro existe; si no, crearla
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Definir los valores a agregar o modificar
    $values = @{
        Manufacturer = "Mggons Support Center"
        Model = "Windows 11 - Update 2024 - S&A"
        SupportHours = "Lunes a Viernes 8AM - 12PM - 2PM - 6PM"
        SupportURL = "https://wa.me/+573144182071"
    }

    # Agregar o modificar los valores en el registro
    foreach ($name in $values.Keys) {
        Set-ItemProperty -Path $regPath -Name $name -Value $values[$name]
    }

    Write-Host "Los datos del OEM han sido actualizados en el registro."
	
Write-Output '56% Completado'
    $folderPath = "C:\Windows.old"

    # Verificar si la carpeta Windows.old existe
    if (Test-Path -Path $folderPath) {
        Write-Host "La carpeta $folderPath existe. Procediendo a eliminarla..."

        # Eliminar la carpeta y su contenido de manera recursiva
        Remove-Item -Path $folderPath -Recurse -Force
        Write-Host "La carpeta $folderPath ha sido eliminada."
    } else {
        Write-Host "La carpeta $folderPath no existe. Omitiendo eliminación."
    }

    Write-Host "Script ejecutado exitosamente en Windows 11."
} else {
    Write-Host "El sistema operativo no es Windows 11 con una compilación 22000 o superior. El script se ha omitido."
}

############## Eliminar el autoinicio de microsoft Edge ####################
# Definir el nombre que se buscarÃ¡
$nombreABuscar = "MicrosoftEdgeAutoLaunch_"

# Obtener todas las entradas en HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
$entradas = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue

# Verificar si hay entradas y eliminar aquellas que contienen el nombre buscado
if ($entradas) {
    foreach ($entrada in $entradas.PSObject.Properties) {
        if ($entrada.Name -like "*$nombreABuscar*") {
            Write-Host "Eliminando entrada $($entrada.Name)"
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $entrada.Name
        }
    }
} else {
    Write-Host "No se encontraron entradas en el Registro."
}
Write-Output '60% Completado'
############## Eliminar el autoinicio de microsoft Edge ####################
# Definir el nombre que se buscarÃ¡
$nombreABuscar = "!BCILauncher"

# Obtener todas las entradas en HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
$entradas = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -ErrorAction SilentlyContinue

# Verificar si hay entradas y eliminar aquellas que contienen el nombre buscado
if ($entradas) {
    foreach ($entrada in $entradas.PSObject.Properties) {
        if ($entrada.Name -like "*$nombreABuscar*") {
            Write-Host "Eliminando entrada $($entrada.Name)"
            Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name $entrada.Name
        }
    }
} else {
    Write-Host "No se encontraron entradas en el Registro."
}
# Establecer la ruta de la clave de registro para Microsoft Edge
$edgeRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

# Verificar si la clave de registro de Edge existe y, si no, crearla
if (!(Test-Path $edgeRegistryPath)) {
    New-Item -Path $edgeRegistryPath -Force | Out-Null
}

# Deshabilitar "Startup Boost"
Set-ItemProperty -Path $edgeRegistryPath -Name "StartupBoostEnabled" -Type DWord -Value 0

# Deshabilitar "Seguir ejecutando extensiones y aplicaciones en segundo plano mientras Edge esté cerrado"
Set-ItemProperty -Path $edgeRegistryPath -Name "BackgroundModeEnabled" -Type DWord -Value 0

Write-Host "Startup Boost y la ejecución en segundo plano de Microsoft Edge han sido deshabilitados."

# Ruta al registro donde se almacena la configuración de bienvenida de Edge
$EdgeRegistryPath = "HKCU:\Software\Microsoft\Edge"

# Verificar si la clave 'Edge' existe en el registro, si no, crearla
if (-not (Test-Path $EdgeRegistryPath)) {
    New-Item -Path $EdgeRegistryPath -Force | Out-Null
}

# Crear o modificar el valor 'HideFirstRunExperience' para omitir la pantalla de bienvenida
Set-ItemProperty -Path $EdgeRegistryPath -Name "HideFirstRunExperience" -Value 1 -Force

# Verificar si se ha creado la configuración
$HideFirstRun = Get-ItemProperty -Path $EdgeRegistryPath -Name "HideFirstRunExperience"

if ($HideFirstRun.HideFirstRunExperience -eq 1) {
    Write-Host "La pantalla de bienvenida de Microsoft Edge ha sido desactivada correctamente."
} else {
    Write-Host "No se pudo desactivar la pantalla de bienvenida de Microsoft Edge."
}

# Verificar si el proceso de Microsoft Edge estÃ¡ en ejecuciÃ³n y detenerlo
$processName = "msedge"
Start-Process "msedge.exe"
Start-Sleep 5
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Write-Host "Deteniendo el proceso $processName..."

    Get-Process -Name $processName | Stop-Process -Force
    Write-Host"Proceso $processName detenido."
} else {
    Write-Host "El proceso $processName no esta en ejecucion."
}
Write-Output '64% Completado'
########################################### 11.MODULO DE OPTIMIZACION DE INTERNET ###########################################
Write-Host "Restringiendo Windows Update P2P solo a la red local..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1

	New-ItemProperty -Path Registry::HKEY_USERS\S-1-5-20\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings -Name DownloadMode -PropertyType DWord -Value 0 -Force
			Delete-DeliveryOptimizationCache -Force

Write-Host "Deshabilitando Cortana..."

# Ensure Personalization Settings Path Exists
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0

# Ensure Input Personalization Path Exists
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1

# Ensure Trained Data Store Path Exists
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0

# Ensure Windows Search Policies Path Exists
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Write-Host "Cortana deshabilitada"

Write-Host "Habilitacion del modo oscuro"
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
    Write-Host "Enabled Dark Mode"
#    $ResultText.text = "`r`n" +"`r`n" + "Enabled Dark Mode"
	
Write-Host "Inhabilitando telemetría..."
Write-Host "Disabling Telemetry..."

# Disable telemetry by setting registry values
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# Disable scheduled tasks related to telemetry
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
Write-Host "Telemetría deshabilitada"

Write-Output '70% Completado'

Write-Host "Inhabilitando Wi-Fi Sense..."
    If (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
        New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

########################################### 11.MODULO DE OPTIMIZACION DE INTERNET ###########################################
    Write-Host "Deshabilitando sugerencias de aplicaciones..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1

    Write-Host "Inhabilitando las actualizaciones automÃ¡ticas de Maps..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
    Write-Host "Disabling Feedback..."
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null

    Write-Host "Inhabilitando experiencias personalizadas..."
    If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
    
    Write-Host "Inhabilitando ID de publicidad..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1

    Write-Host "Deshabilitando informe de errores..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
    Write-Output '76%'    
    Write-Host "Deteniendo y deshabilitando el servicio de seguimiento de diagnÃ³sticos..."
    Stop-Service "DiagTrack" -WarningAction SilentlyContinue
    Set-Service "DiagTrack" -StartupType Disabled
    Write-Host "Stopping and disabling WAP Push Service..."
    Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
    Set-Service "dmwappushservice" -StartupType Disabled
    Write-Host "Stopping and disabling Home Groups services..."
    Stop-Service "HomeGroupListener" -WarningAction SilentlyContinue
    Set-Service "HomeGroupListener" -StartupType Disabled
    Stop-Service "HomeGroupProvider" -WarningAction SilentlyContinue
    Set-Service "HomeGroupProvider" -StartupType Disabled

    Write-Host "Deteniendo y deshabilitando el servicio de seguimiento de diagnó³´©cos..."
    Stop-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue
    Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
    
    Write-Host "Deteniendo y deshabilitando el servicio WAP Push..."
    Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    
    Write-Host "Deteniendo y deshabilitando los servicios de Grupos en el Hogar..."
    Stop-Service -Name "HomeGroupListener" -ErrorAction SilentlyContinue
    Set-Service -Name "HomeGroupListener" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "HomeGroupProvider" -ErrorAction SilentlyContinue
    Set-Service -Name "HomeGroupProvider" -StartupType Disabled -ErrorAction SilentlyContinue
    
    Write-Host "Inhabilitando el sensor de almacenamiento..."
    Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
    Write-Host "Stopping and disabling Superfetch service..."
    Stop-Service "SysMain" -WarningAction SilentlyContinue
    Set-Service "SysMain" -StartupType Disabled

Write-Host "Desactivando HibernaciÃ³n..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0

powercfg.exe /h off

Write-Host "Ocultar el botÃ³n Vista de tareas..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

Write-Host "Icono de personas ocultas..."
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
	
	if (-not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People))
			{
				New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People -Force
			}
			New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People -Name PeopleBand -PropertyType DWord -Value 0 -Force

Write-Host "Ocultar iconos de la bandeja..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 1

Write-Host "Segundos en el relog"
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -PropertyType DWord -Value 1 -Force

Write-Host "Cambiando la vista predeterminada del Explorador a Esta PC..."
    $ResultText.text += "`r`n" +"Quality of Life Tweaks"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

Write-Host "Ocultando el Ã­cono de Objetos 3D de Esta PC..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue

#Network Tweaks
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type DWord -Value 20

Write-Host "Habilitando la oferta de controladores a travÃ©s de Windows Update..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue

Write-Host "Habilitando el reinicio automatico de Windows Update..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue

Write-Host "Oferta de controlador habilitado a travÃ©s de Windows Update"
    $ResultText.text = "`r`n" +"`r`n" + "Set Windows Updates to Stock Settings"

Write-Host "Habilitando proveedor de ubicaciÃ³n..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableWindowsLocationProvider" -ErrorAction SilentlyContinue
	Write-Host "Enabling Location Scripting..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -ErrorAction SilentlyContinue

Write-Host "Habilitando ubicacion."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "Value" -Type String -Value "Allow"

Write-Host "Permitir el acceso a la ubicacion"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Allow"
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value "1"
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation_UserInControlOfTheseApps" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation_ForceAllowTheseApps" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation_ForceDenyTheseApps" -ErrorAction SilentlyContinue
	Write-Host "Done - Reverted to Stock Settings"
    
Write-Output '80% Completado'
Write-Host "Iconos grandes del panel de control"
	if (-not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel))
		{
		New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel -Force
		}
		New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel -Name AllItemsIconView -PropertyType DWord -Value 0 -Force
		New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel -Name StartupPage -PropertyType DWord -Value 1 -Force

Write-Host "Enable Sensor de Almacenamiento x30 dias"
		if (-not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy))
			{
		    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -ItemType Directory -Force
			}
			New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 01 -PropertyType DWord -Value 1 -Force
		
			if ((Get-ItemPropertyValue -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 01) -eq "1")
			{
				New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 2048 -PropertyType DWord -Value 30 -Force
			}


            #Write-Host "Quitar - Aplicaciones agregadas recientemente en el menÃº Inicio"
			#if (-not (Test-Path -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer))
			#{
			#	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Force
			#}
			#New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name HideRecentlyAddedApps -PropertyType DWord -Value 1 -Force
			#New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-338388Enabled -PropertyType DWord -Value 0 -Force


			# Eliminar todas las aplicaciones excluidas que se ejecutan en segundo plano
			Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications | ForEach-Object -Process {
				Remove-ItemProperty -Path $_.PsPath -Name * -Force
			}

			# Excluir aplicaciones del paquete Ãºnicamente
			$BackgroundAccessApplications = @((Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications).PSChildName)
			$ExcludedBackgroundAccessApplications = @()
			foreach ($BackgroundAccessApplication in $BackgroundAccessApplications)
			{
				if (Get-AppxPackage -PackageTypeFilter Bundle -AllUsers | Where-Object -FilterScript {$_.PackageFamilyName -eq $BackgroundAccessApplication})
				{
					$ExcludedBackgroundAccessApplications += $BackgroundAccessApplication
				}
			}

			Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications | Where-Object -FilterScript {$_.PSChildName -in $ExcludedBackgroundAccessApplications} | ForEach-Object -Process {
				New-ItemProperty -Path $_.PsPath -Name Disabled -PropertyType DWord -Value 1 -Force
				New-ItemProperty -Path $_.PsPath -Name DisabledByUser -PropertyType DWord -Value 1 -Force
			}

			# Abra la pÃ¡gina "Aplicaciones en segundo plano"
			#Start-Process -FilePath ms-settings:privacy-backgroundapps

# Asegúrate de ejecutar el script con privilegios administrativos

# Detener el servicio Windows Installer
Write-Host "Deteniendo el servicio Windows Installer..."
Stop-Service -Name msiserver -Force

# Agregar entrada en el registro para configurar MaxPatchCacheSize a 0
Write-Host "Configurando MaxPatchCacheSize a 0..."
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Installer" -Name "MaxPatchCacheSize" -PropertyType DWord -Value 0 -Force

# Eliminar la carpeta de caché de parches
Write-Host "Eliminando la carpeta de caché de parches..."
$patchCachePath = Join-Path $env:WINDIR "Installer\$PatchCache$"
Remove-Item -Path $patchCachePath -Recurse -Force

# Iniciar el servicio Windows Installer
Write-Host "Iniciando el servicio Windows Installer..."
Start-Service -Name msiserver

# Detener el servicio Windows Installer nuevamente
Write-Host "Deteniendo el servicio Windows Installer nuevamente..."
Stop-Service -Name msiserver -Force

# Configurar MaxPatchCacheSize a 10
Write-Host "Configurando MaxPatchCacheSize a 10..."
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Installer" -Name "MaxPatchCacheSize" -PropertyType DWord -Value 10 -Force

# Iniciar el servicio Windows Installer nuevamente
Write-Host "Iniciando el servicio Windows Installer nuevamente..."
Start-Service -Name msiserver

Write-Output '90% Completado'
############################## OPTIMIZAR DISCO SSD #############################
# Función para verificar si el disco es un SSD
function IsSSD {
    param (
        [string]$driveLetter
    )
    $diskNumber = (Get-Partition -DriveLetter $driveLetter).DiskNumber
    $diskInfo = Get-PhysicalDisk | Where-Object { $_.DeviceID -eq $diskNumber }
    return $diskInfo.MediaType -eq 'SSD'
}

# Obtener la letra de unidad del sistema
$systemDriveLetter = ($env:SystemDrive).TrimEnd(':')
Write-Output '93% Completado'
# Verificar si el sistema está en un SSD
if (IsSSD -driveLetter $systemDriveLetter) {
    Write-Host "Optimizando SSD..."
        
    # Desactivar la función de reinicio rápido
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0

    # Desactivar la desfragmentación programada en la unidad C
    Stop-Service -Name "RmSvc" -Force
    Set-Service -Name "RmSvc" -StartupType Disabled

    # Aplicar optimizaciones para SSD
    $volume = Get-Volume -DriveLetter $systemDriveLetter
    if ($volume) {
        # Habilitar restauración del sistema en la unidad del sistema
        Enable-ComputerRestore -Drive "$systemDriveLetter`:\" -Confirm:$false

        # Deshabilitar restauración del sistema en todas las unidades excepto en C:
        Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -ne "$systemDriveLetter`:" -and $_.DriveLetter -ne $null } | ForEach-Object {
            if ($_.DriveLetter) {
                #Disable-ComputerRestore -Drive "$($_.DriveLetter)\"
            }
        }

        Write-Host "Optimizando para SSD - Disco: $($volume.DriveLetter)"
        Write-Output '95% Completado'
        # Configuración de políticas de energía
        powercfg /change standby-timeout-ac 0
        powercfg /change standby-timeout-dc 0
        powercfg /change hibernate-timeout-ac 0
        powercfg /change hibernate-timeout-dc 0

        # Deshabilitar desfragmentación automática
        Disable-ScheduledTask -TaskName '\Microsoft\Windows\Defrag\ScheduledDefrag'

        # ReTrim para SSD
        Optimize-Volume -DriveLetter $volume.DriveLetter -ReTrim -Verbose

        # Deshabilitar Prefetch y Superfetch
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnablePrefetcher -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnableSuperfetch -Value 0

        # Deshabilitar la última fecha de acceso
        fsutil behavior set DisableLastAccess 1

        # Desactivar la compresión NTFS
        fsutil behavior set DisableCompression 1

        # Deshabilitar el seguimiento de escritura en el sistema de archivos
        fsutil behavior set DisableDeleteNotify 1

        Write-Host "Optimización de SSD completa."
        Write-Host "Proceso completado..."
        
        Set-ItemProperty -Path "C:\ODT" -Name "Attributes" -Value ([System.IO.FileAttributes]::Hidden)
    Write-Output '98% Completado'
	# Mantenimiento del sistema
	Write-Host "Haciendo Mantenimiento, Por favor espere..."
	Start-Process -FilePath "dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase" -Wait
    } else {
        Write-Host "No se encontró el volumen para la letra de unidad $systemDriveLetter."
    }

} else {
    # Aplicar optimizaciones para HDD
    Write-Host "Optimizando para HDD - Disco: $($systemDriveLetter)"
    
    # Agrega aquí las optimizaciones específicas para HDD
    $volume = Get-Volume -DriveLetter $systemDriveLetter
    if ($volume) {
        # Habilitar restauración del sistema en la unidad del sistema
        Enable-ComputerRestore -Drive "$systemDriveLetter`:\" -Confirm:$false

        # Deshabilitar restauración del sistema en todas las unidades excepto en C:
        Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -ne "$systemDriveLetter`:" -and $_.DriveLetter -ne $null } | ForEach-Object {
            if ($_.DriveLetter) {
                #Disable-ComputerRestore -Drive "$($_.DriveLetter)\"
            }
        }
        Write-Output '95% Completado'
        # Desactivar la desfragmentación programada
        Disable-ScheduledTask -TaskName '\Microsoft\Windows\Defrag\ScheduledDefrag'

        # Ajustar las opciones de energía para un rendimiento máximo
        powercfg /change standby-timeout-ac 0
        powercfg /change hibernate-timeout-ac 0
        powercfg /change monitor-timeout-ac 0
        powercfg /change disk-timeout-ac 0

        # Desactivar Superfetch y Prefetch
        Stop-Service -Name "SysMain" -Force
        Set-Service -Name "SysMain" -StartupType Disabled
		    Stop-Service -Name "RmSvc" -Force
        Set-Service -Name "RmSvc" -StartupType Disabled								 

        # Desactivar la función de reinicio rápido
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0

        # Desactivar la compresión del sistema
        fsutil behavior set disablecompression 1

        # Desactivar la hibernación
        powercfg.exe /hibernate off

        # Desactivar la grabación de eventos de Windows
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational" -Recurse -Force

        # Desactivar el servicio de telemetría de Windows
        Stop-Service -Name "DiagTrack" -Force
        Set-Service -Name "DiagTrack" -StartupType Disabled

        # Reiniciar el sistema para aplicar los cambios
        Write-Host "Optimizaciones aplicadas. Reiniciando el sistema..."
        Write-Host "Proceso completado..."
        Write-Output '98% Completado'
        # Ocultar la carpeta C:\ODT
        Set-ItemProperty -Path "C:\ODT" -Name "Attributes" -Value ([System.IO.FileAttributes]::Hidden)
        
    } else {
        Write-Host "No se encontró el volumen para la letra de unidad $systemDriveLetter."
        
    }
}

Write-Output '99% Completado'
# Configuración y ejecución de Cleanmgr
Start-Process -FilePath "cmd.exe" -ArgumentList "/c Cleanmgr /sagerun:65535" -WindowStyle Hidden -Wait

# Eliminando carpeta ODT -> Proceso Final
Remove-Item -Path "C:\ODT" -Recurse -Force

# Eliminando Archivo Server -> Proceso Final
Remove-Item -Path "$env:TEMP\server.txt" -Force

Write-Output '100% Completado'
#############################################################################################################################
