$one_drive_location = $env:OneDrive

$backup_file_name_prefix = 'backup_wsl_dev_env'

$wsl_backup_folder = 'wsl_backup'

$back_slash = '\'

$tar_extension = '.tar'

$distro_name = 'Ubuntu'

$current_date = Get-Date -format FileDate

$purge_date_limit = (Get-Date).AddDays(-14)

$backup_file_name = -join($backup_file_name_prefix, '_', $current_date, $tar_extension);

$backup_onedrive_folder = -join($one_drive_location, $back_slash, $wsl_backup_folder);

$backup_filename_to_be_uploaded = -join($backup_onedrive_folder, $back_slash, $backup_file_name);

$file = Get-ChildItem -Path $backup_onedrive_folder -Recurse -File -Include "*$backup_file_name_prefix*"

if (($file).Count -gt 2) {
    try {
        Write-Host "Purging old backups prior to the last two weeks"
        Get-ChildItem -Path $backup_onedrive_folder -Force -Recurse -File | Where-Obejct { !$_.PSIsContainer -and $_.CreationTime -lt $purge_date_limit } | Remove-Item -Force
        Write-Host "Creating backup file"
        wsl --export $distro_name $backup_filename_to_be_uploaded
        Write-Host "Done with backup"
    }
    catch {
        throw $_.Exception.Message
    }
}
# If less than or equal to 2 just backup file
else {
    Write-Host "Creating backup file"
    wsl --export $distro_name $backup_filename_to_be_uploaded
    Write-Host "Done with backup"
}

# [System.Windows.MessageBox]::Show('Backup has completed!', "Backup WSL", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)