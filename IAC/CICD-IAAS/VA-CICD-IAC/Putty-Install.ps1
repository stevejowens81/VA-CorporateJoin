# Install Microsoft's OneGet and start using it

icm $executioncontext.InvokeCommand.NewScriptBlock((New-Object Net.WebClient).DownloadString('https://gist.githubusercontent.com/ianblenke/27f29e3a4a64f0296abe/raw/428e4a8f043d67a1ecce764c1173856f7b1002be/Update-OneGet.ps1')) -ArgumentList $home\Documents\WindowsPowerShellModules\OneGet
Import-Module $home\Documents\WindowsPowerShellModules\OneGet\OneGet.psd1

#Find and Install Putty
find-package *putty*
install-package putty -force