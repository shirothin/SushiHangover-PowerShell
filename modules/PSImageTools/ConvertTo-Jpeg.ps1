#requires -version 2.0
function ConvertTo-Jpeg {
    <#
    .Synopsis
    Converts an image to a JPEG.

    .Description
    The ConvertTo-JPEG function converts image files to JPEG file format.
    You can specify the desired image quality on a scale of 1 to 100.

    ConvertTo-JPEG takes only COM-based image objects of the type that Get-Image returns.
    To use this function, use the Get-Image function to create image objects for the image files, 
    then submit the image objects to ConvertTo-JPEG.

    The converted files have the same name and location as the original files but with a .JPG file name extension.
    If a file with the same name already exists in the location, ConvertTo-JPEG declares an error. 

    .Parameter Image
    Specifies the image objects to convert.
    The objects must be of the type that the Get-Image function returns.
    Enter a variable that contains the image objects or a command that gets the image objects, such as a Get-Image command.
    This parameter is optional, but if you do not include it, ConvertTo-JPEG has no effect.

    .Parameter Quality
    A number from 1 to 100 that indicates the desired quality of the JPEG.
    The default is 100, which represents the best possible quality.

    .Parameter HideProgress
    Hides the progress bar.

    .Parameter Remove
    Deletes the original file.
    By default, both the original file and new JPEG are saved. 

    .Notes
    ConvertTo-JPEG uses the Windows Image Acquisition (WIA) Layer to convert files.

    .Link
    "Image Manipulation in PowerShell": http://blogs.msdn.com/powershell/archive/2009/03/31/image-manipulation-in-powershell.aspx

    .Link
    "ImageProcess object": http://msdn.microsoft.com/en-us/library/ms630507(VS.85).aspx

    .Link 
    Get-Image

    .Link
    ConvertTo-Bitmap

    .Example
    Get-Image .\MyPhoto.png | ConvertTo-Jpeg

    .Example
    # Deletes the original BMP files.
    dir .\*.bmp | get-image | ConvertTo-Jpeg –quality 100 –remove -hideProgress

    .Example
    $photos = dir $home\Pictures\Vacation\* -recurse –include *.bmp, *.png, *.gif
    $photos | get-image | convertTo-JPEG
    #>
    param(
    [Parameter(ValueFromPipeline=$true)]    
    $Image,
    
    [ValidateRange(1,100)]
    [int]$Quality = 100
    )
    process {
        if (-not $image.Loadfile -and 
            -not $image.Fullname) { return }
        $realItem = Get-Item -ErrorAction SilentlyContinue $image.FullName
        if (-not $realItem) { return }
        if (".jpg",".jpeg" -notcontains $realItem.Extension) {
            $noExtension = $realItem.FullName.Substring(0, 
                $realItem.FullName.Length - $realItem.Extension.Length)
            $process = New-Object -ComObject Wia.ImageProcess
            $convertFilter = $process.FilterInfos.Item("Convert").FilterId
            $process.Filters.Add($convertFilter)
            $process.Filters.Item(1).Properties.Item("Quality") = $quality
            $process.Filters.Item(1).Properties.Item("FormatID") = "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}"
            $newImg = $process.Apply($image.PSObject.BaseObject)
            $newImg.SaveFile("$noExtension.jpg")
            if (-not $hideProgress) {
                Write-Progress "Converting Image" $realItem.Fullname
            }
            if ($remove) {
                $realItem | Remove-Item
            }
        }
    
    }
}
 
