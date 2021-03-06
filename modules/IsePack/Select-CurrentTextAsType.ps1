function Select-CurrentTextAsType {   
    <#
    .Synopsis
        Attempts to select the current text as a type
    .Description
        Attempts to select the current text as a type.
        Will not display errors for selections that could not be coerced into a 
        type 
    .Example
        Select-CurrentTextAsType
    #>
    param()
    Select-CurrentText | ForEach-Object {
        if ($_ -as [Type]) {
            $_ -as [Type]
        } else {
            if ($_ -and ($_.Trim("[]") -as [Type])) { 
                $_.Trim("[]") -as [Type]
            }
        }
    }
}
