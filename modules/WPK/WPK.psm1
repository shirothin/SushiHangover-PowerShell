param([switch]$refresh, [string[]]$commandList, [Type[]]$additionalTypes) 

$WinFormsIntegration = "WindowsFormsIntegration, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"

try {
    $Assemblies = [Reflection.Assembly]::LoadWithPartialName("WindowsBase"),
        [Reflection.Assembly]::LoadWithPartialName("PresentationFramework"),
        [Reflection.Assembly]::LoadWithPartialName("PresentationCore"),
        [Reflection.Assembly]::Load($WinFormsIntegration)
} catch {
    throw $_
}

# Import the rules engine
. $psScriptRoot\Add-CodeGenerationRule.ps1
# Import the individual rules
. $psScriptRoot\Rules\WPFCodeGenerationRules.ps1

# Import the worker commands
. $psScriptRoot\ConvertFrom-TypeToScriptCmdlet.ps1
. $psScriptRoot\ConvertTo-ParameterMetaData.ps1

$Scripts = Get-ChildItem $psScriptRoot\GeneratedControls `
    -ErrorAction SilentlyContinue -Filter *.ps1
        
if (-not $Scripts) {
    # Create the controls directory
    $null = New-Item -Path $psScriptRoot\GeneratedControls -Type Directory `
        -ErrorAction SilentlyContinue

    foreach ($Assembly in $Assemblies) {
        if (-not $Assembly) { continue } 
        $Name = $assembly.GetName().Name
        Write-Progress "Creating Commands" $Name 
        $Results = $Assembly.GetTypes() | 
            Where-Object {
                $_.IsPublic -and
                (-not $_.IsGenericType) -and 
                ($_.FullName -notlike "*Internal*")
            } |
            ConvertFrom-TypeToScriptCmdlet -ErrorAction SilentlyContinue
        $path = "$psScriptRoot\GeneratedControls\$Name.ps1"
        [IO.File]::WriteAllText($Path, $Results)
    }
    
    $Scripts = Get-ChildItem $psScriptRoot\GeneratedControls `
        -ErrorAction SilentlyContinue -Filter *.ps1
}

# Import the scritpts directory
foreach ($s in $scripts) { 
    . $s.FullName
}

foreach ($s in Get-ChildItem $psScriptRoot\Controls -Filter *.ps1 `
    -ErrorAction SilentlyContinue) {
    if (-not $s) { continue }
    . $s.FullName
}

. $psScriptRoot\Add-ChildControl.ps1
. $psScriptRoot\Add-GridRow.ps1
. $psScriptRoot\Add-GridColumn.ps1
. $psScriptRoot\Add-EventHandler.ps1
. $psScriptRoot\Close-Control.ps1
. $psScriptRoot\Copy-DependencyProperty.ps1
. $psScriptRoot\ConvertTo-DataTemplate.ps1
. $psScriptRoot\ConvertTo-GridLength.ps1
. $psScriptRoot\ConvertTo-Xaml.ps1
. $psScriptRoot\Get-ChildControl.ps1
. $psScriptRoot\Get-DependencyProperty.ps1
. $psScriptRoot\Get-PowerShellDataSource.ps1
. $psScriptRoot\Get-Resource.ps1
. $psScriptRoot\Get-ReferencedCommand.ps1
. $psScriptRoot\Get-HashtableAsObject.ps1
. $psScriptRoot\Enable-Multitouch.ps1
. $psScriptRoot\Export-Application.ps1
. $psScriptRoot\Hide-UIElement.ps1
. $psScriptRoot\Move-Control.ps1
. $psScriptRoot\Register-PowerShellCommand.ps1
. $psScriptRoot\Remove-ChildControl.ps1
. $psScriptRoot\Show-UIElement.ps1
. $psScriptRoot\Show-Window.ps1
. $psScriptRoot\Set-DependencyProperty.ps1
. $psScriptRoot\Set-Property.ps1
. $psScriptRoot\Set-Resource.ps1
. $psScriptRoot\Start-PowerShellCommand.ps1
. $psScriptRoot\Start-Animation.ps1
. $psScriptRoot\Start-wPFJob.ps1
. $psScriptRoot\Stop-PowerShellCommand.ps1
. $psScriptRoot\Update-WPFJob.ps1
. $psScriptRoot\Unregister-PowerShellCommand.ps1
