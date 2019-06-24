from pathlib import Path
import platform

# Set up backup folder path here
sysPlatform = platform.system()

if sysPlatform == 'Windows':
    p = '/Program Files/FileMaker Server/Data/Backups/'
else:
    p = '/Library/FileMaker Server/Data/Backups/'

backupPath = Path(p)
print(backupPath)





