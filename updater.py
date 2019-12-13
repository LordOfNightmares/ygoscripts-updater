import traceback
from tempfile import TemporaryDirectory


def power_shell():
    code = r'''function CheckAndInstallGit {
 
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
     
     
    CheckAndInstallGit -Repo "git-for-windows" -TempDir "c:\temp"'''
    return code


def system_conf():
    if "system_user.conf" in os.listdir():
        return "system_user.conf"
    elif "system.conf" in os.listdir():
        return "system.conf"


def update_line(l, line):
    for i in l:
        if line in i:
            l[l.index(i)] = 'prefer_expansion_script = 1'
            return
    l.append('prefer_expansion_script = 1')


def output(file, l):
    if file == system_conf():
        if system_conf() != "system_user.conf":
            file = "system_user.conf"
        out = open(file, 'w+', encoding='utf-8')
        for i in range(len(l)):
            out.write(l[i] + "\n")


if __name__ == '__main__':

    try:
        import subprocess
        import os
        print('\nPlease wait checking for Git installation if not installed it will be installed now.')
        with TemporaryDirectory() as tmp:
            abs = os.path.join(os.path.abspath(tmp), 'git_install.ps1')
            with open(abs, 'w') as file:
                file.write(power_shell())
                print(abs)
            bashCommand = 'powershell -executionpolicy bypass -File ' + abs
            print(bashCommand)
            process = subprocess.run(bashCommand)

        from methods.configuration import Config
        from methods.git_methods import git_clone

        path = "expansions"
        name_of_content = 'Expansions'
        git_url = "https://github.com/LordOfNightmares/expansions.git"
        conf = Config('config.yaml')
        if system_conf():
            openfile = open(system_conf(), 'r', encoding='utf-8')
            read_line = [line.strip() for line in openfile]
            update_line(read_line, "prefer_expansion_script")
            output(system_conf(), read_line)
        try:
            config_loaded = conf.load()
            if name_of_content not in config_loaded:
                conf.update({name_of_content: git_url}, append=True)
                config_loaded = conf.load()
        except:
            conf.update({name_of_content: git_url})
            config_loaded = conf.load()
        print(config_loaded[name_of_content])
        git_clone(path, config_loaded[name_of_content], '.')
    except:
        print(traceback.format_exc())
    finally:
        input("Press enter to leave")
