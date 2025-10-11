# Build and run OpenVR Loading Test Application
# Usage: .\build-and-run.ps1

Write-Host "Building BoneworksAslHelper..." -ForegroundColor Cyan
dotnet build BoneworksAslHelper\BoneworksAslHelper.csproj -c Release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to build BoneworksAslHelper" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuilding TestOpenVRLoading..." -ForegroundColor Cyan
dotnet build TestOpenVRLoading\TestOpenVRLoading.csproj -c Release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to build TestOpenVRLoading" -ForegroundColor Red
    exit 1
}

Write-Host "`nCopying dependencies..." -ForegroundColor Cyan
Copy-Item -Force BoneworksAslHelper\bin\Release\net9.0\BoneworksAslHelper.dll TestOpenVRLoading\bin\Release\net9.0\
# openvr_api.dll will be loaded from Boneworks installation automatically

Write-Host "`nRunning TestOpenVRLoading..." -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green
.\TestOpenVRLoading\bin\Release\net9.0\TestOpenVRLoading.exe
