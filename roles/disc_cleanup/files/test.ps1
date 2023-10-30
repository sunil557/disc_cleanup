#$Block = {
param (
	[string]$Username,
	[string]$Password,
	[string]$Source,
	[string]$Days,
	[string]$DriveName
) 

Write-Output ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)

#$Username = "windows"
#$Password = "Welcome@1Welcome@1"
#$Password = ConvertTo-SecureString -string "$Password" -AsPlainText -Force 

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
Write-Output ("SecurePassword: ${SecurePassword}")

$Creds = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)


#$Source = "\\win1\new_share"
#$Days = "0"
#$DriveName="E"

$DrivePath=$DriveName+":\"

Write-Output ("Username: ${Username}")
Write-Output ("After_stg_passwd: ${Password}")
Write-Output ("Credss: ${Creds}")
Write-Output ("Source: ${Source}")
Write-Output ("Days: ${Days}")
Write-Output ("DriveName: ${DriveName}")

If ( Test-Path -path $DrivePath)
{

Remove-PSDrive -Name $DriveName

}

else
{
Write-Output "Not removed"
}

New-PSDrive -Name $DriveName -Root $Source  -PSProvider "FileSystem" -Credential $Creds


#$Days=100
#$SharePath='\\DERUSUSRFL003.ey.net\003RUU10030\N\NADD_Files\_Data_transfer'
#cd $SharePath
$Filenames=(dir $DrivePath | select * | Sort-Object Name | select-object Name).Name

Write-Output ("file_names: ${Filenames}")
Write-Output ("DrivePath: ${TruePath}")

if (!(Test-Path "$DrivePath\logs"))
{
	New-Item -ItemType "Directory" -Path "$DrivePath\logs"
}
else
{
	Write-Output "$DrivePath\logs"
}

if (!(Test-Path "$DrivePath\logs\$(get-date -f yyyy-MM-dd).log"))
{
	New-Item -ItemType "file" -Path "$DrivePath\logs\$(get-date -f yyyy-MM-dd).log"
}
else
{
	Write-Output "$DrivePath\logs\$(get-date -f yyyy-MM-dd).log"
}


foreach ( $Filename in $Filenames)
{
$TruePath=$DrivePath+'\'+$Filename
$Files=Get-ChildItem -Recurse -LiteralPath $TruePath | Where-Object { !$_.PSIsContainer -and  ($_.CreationTime -lt (get-date).adddays(-$Days)) -and ($_.LastWriteTime -lt (get-date).adddays(-$Days)) }

if ($Files.count -gt 0)
{

	ForEach( $File in $Files)
	{
		Write-Output $File.FullName
		Remove-Item -Path $File.FullName -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
		Add-Content -Path "$DrivePath\logs\$(get-date -f yyyy-MM-dd).log" -Value $File.FullName
	}
}
}

#Get-ChildItem -Path \\DERUSUSRFL003.ey.net\003RUU10030\N\NADD_Files\OT30D\_Data_transfer -Recurse | foreach { Write-Output $_.Name }

#$FolderPath="\\DERUSUSRFL003.ey.net\003RUU10030\N\NADD_Files\OT30D\_Data_transfer\AV Center Rental"
#Test-Path -Path $FolderPath

If ( Test-Path -path $DrivePath)
{

Remove-PSDrive -Name $DriveName

}

else
{
Write-Output "Not removed"
}

# }

# $Session = New-PSSession -ComputerName win1 -Credential (New-Object PSCredential -ArgumentList $Username, (ConvertTo-SecureString -String $Password -AsPlainText -Force))
# Invoke-Command -ScriptBlock $Block -ArgumentList $Username, $Password, $Source, $DriveName -Session $Session
# Remove-PSSession $Session
