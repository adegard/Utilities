# Silently uninstall Yandex Browser
# Get the Yandex Browser uninstall string
[string]$YandexUninstallString = Get-Package -Name Yandex -ErrorAction Ignore | ForEach-Object -Process {$_.Meta.Attributes["UninstallString"]}
if ($YandexUninstallString)
{
	# Stop all Yandex Browser processes
	Stop-Process -Name browser, searchbandapp64 -Force
	Get-Service -Name YandexBrowserService | Stop-Service -Force

	# Backup the Yandex Browser bookmarks before removing. Bookmarks (without an extension) This is just a JSON file
	# Get the current user Desktop folder location
	$DesktopFolderLocation = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Desktop
	Get-Item -Path "$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\Bookmarks" -Force | Copy-Item -Destination $DesktopFolderLocation -Force

	# Get arguments
	[string[]]$YandexBrowserSetup = ($YandexUninstallString -Replace("\s*--",",--")).Split(",").Trim()
	# Uninstall Yandex Browser
	Start-Process -FilePath $YandexBrowserSetup[0] -ArgumentList "$YandexBrowserSetup[1..2] --force-uninstall" -Wait

	# Get the pinned Yandex button uninstall string. In Russian only
	[string]$YandexUninstallString = Get-Package -Name "Кнопка `"Яндекс`" на панели задач" | ForEach-Object -Process {$_.Meta.Attributes["UninstallString"]}
	# Get arguments
	[string[]]$YandexBrowserSetup = ($YandexUninstallString -Replace("\s*--",",--")).Split(",").Trim()
	# Uninstall the Yandex button
	Start-Process -FilePath $YandexBrowserSetup[0] -ArgumentList $YandexBrowserSetup[1..1] -Wait

	# Remove leftovers
	$YandexTrails = @(
		"$env:TEMP\pin",
		"$env:TEMP\YaLogs",
		"$env:TEMP\yandex_browser_installer.log",
		"$env:TEMP\YandexWorking.exe",
		"$env:LOCALAPPDATA\Yandex",
		"$env:APPDATA\Yandex"
	)
	Remove-Item -Path $YandexTrails -Recurse -Force
}
