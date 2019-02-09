# escape=`

ARG BASE_TAG=latest_1803

FROM mback2k/windows-buildbot-tools:${BASE_TAG}

SHELL ["powershell", "-command"]

ARG PELLESC_SETUP="https://www.pellesc.de/download_start.php?file=900/setup.exe"

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest $env:PELLESC_SETUP -OutFile "C:\Windows\Temp\pellesc_setup.exe"; `
    Start-Process -FilePath "C:\Windows\Temp\pellesc_setup.exe" -ArgumentList /S -NoNewWindow -PassThru -Wait; `
    Remove-Item @('C:\Windows\Temp\*', 'C:\Users\*\Appdata\Local\Temp\*') -Force -Recurse; `
    Write-Host 'Checking INCLUDE ...'; `
    Get-Item -Path 'C:\Program Files\PellesC\Include\Win'; `
    Get-Item -Path 'C:\Program Files\PellesC\Include';

RUN Write-Host 'Updating INCLUDE ...'; `
    $env:INCLUDE = 'C:\Program Files\PellesC\Include\Win;' + $env:INCLUDE; `
    $env:INCLUDE = 'C:\Program Files\PellesC\Include;' + $env:INCLUDE; `
    [Environment]::SetEnvironmentVariable('INCLUDE', $env:INCLUDE, [EnvironmentVariableTarget]::Machine);

SHELL ["cmd.exe", "/s", "/c"]

ARG PUREBASIC_X86="PureBasic_5_61_x86.exe"
ARG PUREBASIC_X64="PureBasic_5_61_x64.exe"

ADD purebasic/PureBasic.prefs C:\Users\ContainerAdministrator\AppData\Roaming\PureBasic\PureBasic.prefs

ADD purebasic/${PUREBASIC_X86} C:\Temp\PureBasic_x86.exe
ADD purebasic/${PUREBASIC_X64} C:\Temp\PureBasic_x64.exe

RUN C:\Temp\PureBasic_x86.exe /VERYSILENT
RUN C:\Temp\PureBasic_x64.exe /VERYSILENT

SHELL ["powershell", "-command"]

RUN Copy-Item 'C:\Program Files (x86)\Windows Kits\10\Lib\10.*\um\x64\*.lib' 'C:\Program Files\PureBasic\PureLibraries\Windows\Libraries'; `
    Copy-Item 'C:\Program Files (x86)\Windows Kits\10\Lib\10.*\um\x86\*.lib' 'C:\Program Files (x86)\PureBasic\PureLibraries\Windows\Libraries';
