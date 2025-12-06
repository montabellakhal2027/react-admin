timestamp=$(date +%Y%m%d%H%M)
backup_file="mydb-$timestamp.sql"


mysqldump -u root -pmy_password mydb > $backup_file


aws --endpoint-url=http://localhost:4566 s3 cp $backup_file s3://react-admin-backups/

