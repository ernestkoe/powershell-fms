# configure backup folder path here
$BACKUP_FOLDER = "C:\Program Files\FileMaker\FileMaker Server\Data\Backups"

function RecurseFolders([string]$path) {

  $s3 = @{
    BucketName = 'deimos-fms-backups'
    Region = 'us-east-1'
    }

  $fc = New-Object -com Scripting.FileSystemObject
  $folder = $fc.GetFolder($path)

  # Iterate through subfolders
  foreach ($i in $folder.SubFolders) {
    $thisFolder = $i.Path

    # Transform the local directory path to notation compatible with S3 Buckets and Folders
    # 1. Trim off the drive letter and colon from the start of the Path
    $s3Path = $thisFolder.ToString()
    $s3Path = $s3Path.SubString(2)
    $s3PathNew = $s3Path -replace $BACKUP_FOLDER, ""
    Write-Host $s3PathNew
    # 2. Replace back-slashes with forward-slashes
    # Escape the back-slash special character with a back-slash so that it reads it literally, like so: "\\"
    $s3Path = $s3Path -replace "\\", "/"

    # Upload directory to S3
    # Write-S3Object -BucketName $s3.BucketName -Folder $thisFolder -KeyPrefix $s3Path
  }

  # If subfolders exist in the current folder, then iterate through them too
  foreach ($i in $folder.subfolders) {
    RecurseFolders($i.path)
  }

Write-Host "mock delete $i.path"
}

RecurseFolders($BACKUP_FOLDER)
