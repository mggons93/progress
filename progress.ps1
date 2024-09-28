[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

# Crear la ventana WPF
$window = New-Object Windows.Window
$window.WindowStartupLocation = 'CenterScreen'
$window.WindowStyle = 'None'
$window.ResizeMode = 'NoResize'
$window.AllowsTransparency = $true
$window.Background = "Black"
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
$textBlock.FontSize = 40
$textBlock.HorizontalAlignment = 'Center'
$textBlock.Margin = "0,0,0,20"  # Espacio entre el texto y el porcentaje

# Crear un TextBlock para mostrar el porcentaje
$percentageTextBlock = New-Object Windows.Controls.TextBlock
$percentageTextBlock.Text = "0%"
$percentageTextBlock.Foreground = 'Green'
$percentageTextBlock.FontSize = 30
$percentageTextBlock.HorizontalAlignment = 'Center'

# Añadir el texto y el porcentaje al StackPanel
$stackPanel.Children.Add($textBlock)
$stackPanel.Children.Add($percentageTextBlock)

# Añadir el StackPanel a la ventana
$window.Content = $stackPanel

# Deshabilitar interacción del usuario
$window.IsHitTestVisible = $false

# Mostrar la ventana
$window.Show()

# Simular puntos de proceso en tu script
$points = @(0, 10, 30, 50, 70, 90, 100)  # Incluir 0% y 100% para mostrar el progreso completo
foreach ($point in $points) {
    Start-Sleep -Seconds 2  # Simula un proceso de optimización

    # Actualizar el porcentaje
    $percentageTextBlock.Text = "$point%"

    # Refrescar la ventana para mostrar los cambios
    $window.Dispatcher.Invoke([Action] { $percentageTextBlock.InvalidateVisual() })
}

# Cerrar la ventana al completar el proceso
$window.Close()
