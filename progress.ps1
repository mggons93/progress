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

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

# Crear la ventana WPF
$window = New-Object Windows.Window
$window.WindowStartupLocation = 'CenterScreen'
$window.WindowStyle = 'None'
$window.ResizeMode = 'NoResize'
$window.AllowsTransparency = $true
$window.Background = [Windows.Media.Brushes]::Black  # Color de fondo negro
$window.WindowState = 'Maximized'
$window.Topmost = $true

# Crear un StackPanel para alinear el texto
$stackPanel = New-Object Windows.Controls.StackPanel
$stackPanel.HorizontalAlignment = 'Center'
$stackPanel.VerticalAlignment = 'Center'
$stackPanel.Orientation = 'Vertical'
$stackPanel.Margin = "0,0,0,0"

# Crear el texto en pantalla
$textBlock = New-Object Windows.Controls.TextBlock
$textBlock.Text = "Optimizando Windows, Espere..."
$textBlock.Foreground = 'White'
$textBlock.FontSize = 24  # Tamaño de fuente
$textBlock.HorizontalAlignment = 'Center'
$textBlock.Margin = "0,0,0,3"  # Espacio reducido entre el texto y el siguiente

# Crear un TextBlock para mostrar el porcentaje
$percentageTextBlock = New-Object Windows.Controls.TextBlock
$percentageTextBlock.Text = "0%"
$percentageTextBlock.Foreground = 'White'  # Color blanco
$percentageTextBlock.FontSize = 24  # Tamaño de fuente
$percentageTextBlock.HorizontalAlignment = 'Center'
$percentageTextBlock.Margin = "0,0,0,0"  # Sin espacio entre el porcentaje y "Completado"

# Crear un TextBlock para mostrar "Completado"
$completedTextBlock = New-Object Windows.Controls.TextBlock
$completedTextBlock.Text = "Completado"
$completedTextBlock.Foreground = 'White'  # Color blanco
$completedTextBlock.FontSize = 24  # Tamaño de fuente
$completedTextBlock.HorizontalAlignment = 'Left'
$completedTextBlock.Margin = "5,0,0,0"  # Espacio reducido a la izquierda

# Crear un StackPanel horizontal para el porcentaje y "Completado"
$progressPanel = New-Object Windows.Controls.StackPanel
$progressPanel.Orientation = 'Horizontal'
$progressPanel.HorizontalAlignment = 'Center'
$progressPanel.Children.Add($percentageTextBlock)
$progressPanel.Children.Add($completedTextBlock)

# Añadir los elementos al StackPanel principal
$stackPanel.Children.Add($textBlock)
$stackPanel.Children.Add($progressPanel)

# Crear un TextBlock para mostrar "No apagues el equipo"
$noApaguesTextBlock = New-Object Windows.Controls.TextBlock
$noApaguesTextBlock.Text = "No apagues el equipo"
$noApaguesTextBlock.Foreground = 'White'  # Color blanco
$noApaguesTextBlock.FontSize = 24  # Tamaño de fuente
$noApaguesTextBlock.HorizontalAlignment = 'Center'
$noApaguesTextBlock.Margin = "0,5,0,0"  # Espacio reducido arriba

# Añadir el mensaje "No apagues el equipo" al StackPanel
$stackPanel.Children.Add($noApaguesTextBlock)

# Crear un TextBlock para "Soporte y Aportes"
$supportTextBlock = New-Object Windows.Controls.TextBlock
$supportTextBlock.Text = "Soporte y Aportes"
$supportTextBlock.Foreground = 'White'  # Color blanco
$supportTextBlock.FontSize = 14  # Tamaño de fuente 14
$supportTextBlock.HorizontalAlignment = 'Center'
$supportTextBlock.Margin = "0,20,0,0"  # Espacio arriba

# Añadir "Soporte y Aportes" al StackPanel
$stackPanel.Children.Add($supportTextBlock)

# Añadir el StackPanel a la ventana
$window.Content = $stackPanel

# Deshabilitar interacción del usuario
$window.IsHitTestVisible = $false

# Mostrar la ventana
$window.Show()

# Simular puntos de proceso en tu script
$points = @(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)  # Incrementos de 10%
foreach ($point in $points) {
    Start-Sleep -Seconds 2  # Simula un proceso de optimización

    # Actualizar el porcentaje
    $window.Dispatcher.Invoke([Action]{
        $percentageTextBlock.Text = "$point%"
    })

    # Aquí puedes agregar el código que deseas ejecutar en cada punto
    if ($point -eq 10) {
        # Bloque de código para el 10%
        # Agrega el código a ejecutar en este punto del progreso
    }
    elseif ($point -eq 20) {
        # Bloque de código para el 20%
        # Agrega el código a ejecutar en este punto del progreso
    }
    elseif ($point -eq 30) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
	elseif ($point -eq 40) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
	elseif ($point -eq 50) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
    # Repite esto para los otros puntos (40%, 50%, etc.)
	elseif ($point -eq 60) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
    # Repite esto para los otros puntos (40%, 50%, etc.)
	elseif ($point -eq 70) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
    # Repite esto para los otros puntos (40%, 50%, etc.)
	elseif ($point -eq 80) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
    # Repite esto para los otros puntos (40%, 50%, etc.)
	elseif ($point -eq 90) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
	elseif ($point -eq 100) {
        # Bloque de código para el 30%
        # Agrega el código a ejecutar en este punto del progreso
    }
    
}

# Cerrar la ventana al completar el proceso
$window.Dispatcher.Invoke([Action] {
    $window.Close()
})
