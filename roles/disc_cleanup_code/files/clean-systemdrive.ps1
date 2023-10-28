Write-Output ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)

$Username = "${username}"
$Password = "${password}"
$Password = ConvertTo-SecureString -string "$Password" -AsPlainText -Force 

$Creds = new-object System.Management.Automation.PSCredential ($Username , $Password)

$Source = "\\DERUSUSRFL003.ey.net\003RUU10030\N\NADD_Files\_Data_transfer"
$Days = 30

"Local server (RAS Secuasus) - 
delete the folder 
\\DERUSUSRFL003.ey.net\003RUU10030\N\NADD_Files
\\DERUSUSRFL003.ey.net\003RUU10030\N\NADD_Files\OT30D"


$DriveName="OO_NADD"
$DrivePath=$DriveName+":\"


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
$TruePath=$DrivePath+'\'+$Filename+'\'
$Files=Get-ChildItem -Recurse -LiteralPath $TruePath | Where-Object { !$_.PSIsContainer -and  ($_.CreationTime -lt (get-date).adddays(-$Days)) -and ($_.LastWriteTime -lt (get-date).adddays(-$Days)) }

if ($Files.count -gt 0)
{

	ForEach( $File in $Files)
	{
		Write-Output $File.FullName
		Remove-Item -Path $File.FullName -Force -ErrorAction SilentlyContinue
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
