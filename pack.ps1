# Paths
$packFolder = (Get-Item -Path "./" -Verbose).FullName
$slnPath = Join-Path $packFolder "/"
$srcPath = Join-Path $slnPath "src"

# List of projects
$projects = (
    "ClassLibrary2.Sdk"
)

# Rebuild solution
Set-Location $slnPath
& dotnet restore

# Copy all nuget packages to the pack folder
foreach($project in $projects) {
    
    $projectFolder = Join-Path $srcPath $project

    # Create nuget pack
    Set-Location $projectFolder
    Remove-Item -Recurse (Join-Path $projectFolder "bin/Release")
    & dotnet msbuild /p:Configuration=Release /p:SourceLinkCreate=true
    & dotnet msbuild /t:pack /p:Configuration=Release /p:SourceLinkCreate=true

    # Copy nuget package
    $projectPackPath = Join-Path $projectFolder ("/bin/Release/" + $project + ".*.nupkg")
    Move-Item $projectPackPath $packFolder

}

# Go back to the pack folder
Set-Location $packFolder

Write-Host ""
Write-Host "��ѡ��Ҫ������nuget��ַ��"
Write-Host ""
Write-Host "=============================="
Write-Host ""
Write-Host "����1����������https://localhost:44325/nuget"
Write-Host ""
Write-Host "����2����������https://www.nuget.org"
Write-Host ""
Write-Host "����3�����������˳���"
Write-Host ""
Write-Host "=============================="
Write-Host ""
Write-Host ""
$user_input = Read-Host '����������'
if ($user_input -ne 3) {
    foreach ($packfile in Get-ChildItem -Path $packFolder -Recurse -Include *.nupkg) {
        if ($user_input -eq 1){
			tools\nuget\nuget.exe push $packfile 123456789 -Source https://localhost:44325/nuget
        }
        if ($user_input -eq 2){
            tools\nuget\nuget.exe push $packfile -Source https://www.nuget.org/api/v2/package d0625654-d5e2-4b82-974e-xxxxxxxx
        }
    }
}
del *.nupkg
pause
exit