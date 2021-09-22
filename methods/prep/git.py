import os
import subprocess
from tempfile import TemporaryDirectory


def shell_code():
    return r'''function CheckAndInstallGit {

    Param(
        [string]$Repo,
        [string]$TempDir

    )

    try {

        git --version

    } Catch {

        Write-host "Git not available on your device. " -ForegroundColor Yellow
        Write-host ": Downloading and installing git..." -ForegroundColor Yellow
        $InstallGit = $True
    }

    If($InstallGit){

        $releases = "https://api.github.com/repos/$repo/git/releases"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Response = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)

        $DownloadUrl = $Response.assets | where{$_.name -match "-64-bit.exe" -and $_.name -notmatch "rc"} | sort created_at -Descending | select -First 1


        If(!(test-path $TempDir))
        {
              New-Item -ItemType Directory -Force -Path $TempDir | out-null
        }

        # --- Download the file to the current location
        Write-host "Trying to download $($repo) on your Device.." -ForegroundColor Yellow

        Try{
            $OutputPath = "$TempDir\$($DownloadUrl.name)"
            Invoke-RestMethod -Method Get -Uri $DownloadUrl.browser_download_url -OutFile $OutputPath -ErrorAction Stop

        } Catch {
            Write-host $_.exception.message
            Write-host "Failed to install Git on your laptop, download and install GIT Manually." -ForegroundColor Red
            Write-host "Download Location: https://gitforwindows.org/" -ForegroundColor Yellow 

        }

        Write-host "Trying to install GIT on your Device.." -ForegroundColor Yellow

        Try{
            $arguments = "/SILENT"
            Start-Process $OutputPath $arguments -Wait -ErrorAction Stop
        } Catch {
            Write-host $_.exception.message
            Write-host "Failed to install Git on your laptop, download and install GIT Manually." -ForegroundColor Red
            Write-host "Download Location: https://gitforwindows.org/" -ForegroundColor Yellow 
        }

        } Else {
            Write-host "Git is already installed, no action needed." -ForegroundColor Green
        }


    }

    CheckAndInstallGit -Repo "git-for-windows" -TempDir "c:\temp"
    '''


def folder_preparation():
    fnames = ['ygorepos', 'script']
    for fname in fnames:
        try:
            os.makedirs(fname)
        except OSError:
            pass


def git_install():
    print('\nPlease wait checking for Git installation if not installed it will be installed now.')
    with TemporaryDirectory() as tmp:
        abs = os.path.join(os.path.abspath(tmp), 'git_install.ps1')
        with open(abs, 'w') as file:
            file.write(shell_code())
        subprocess.run('powershell -executionpolicy bypass -File ' + abs)


def git_pull():
    if len(os.listdir("ygorepos")) == 0:
        subprocess.run("git_set.bat")
        return
    if input("Update Repos(y/n)") == 'y':
        subprocess.run("git_pull.bat")


def preparation():
    folder_preparation()
    git_install()
    git_pull()
