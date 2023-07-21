
$File_name = "C:\temp\DB-tracking-log.txt"

$MysqlUser  = 'root'
$MysqlPass  = 'password'
Set-Location "C:\Program Files\MySQL\MySQL Server 8.0\bin"
$Query = " SELECT TABLE_SCHEMA, table_name, MIN(create_time), MIN(update_time) FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ('mysql','sys','information_schema','performance_schema') GROUP BY TABLE_NAME;"
$data = $(.\mysql -u $MysqlUser -p"$MysqlPass" -e $Query) 
$data | Format-List * > $File_name
$old_file = Get-Content -Path C:\temp\DB-tracking-log-old.txt
$new_file = Get-Content -Path C:\temp\DB-tracking-log.txt

$body_old = Get-Content -Path C:\temp\DB-tracking-log-old.txt -Raw
$body_new = Get-Content -Path C:\temp\DB-tracking-log.txt -Raw


#Send mail
$EmailFrom = "test01@abc.com"
$EmailTo = "JayceL@gmail.com"
$Subject ="Database Changes Alerts on $((Get-Date).ToString()) !!!!!"

$SMTPServer = "12.21.89.76"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("test01@abc.com", "PasswordHint");
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }


If ((Get-Content -Path C:\temp\DB-tracking-log.txt | Where-Object {$_ -notin $old_file}) -ne $Null)  {
      $body_diff = Get-Content -Path C:\temp\DB-tracking-log.txt | Where-Object {$_ -notin $old_file}
      $Body = "Database change alerts `nBefore: `n$body_old`nAfter: `n$body_new`nDiff: `n$body_diff" 
      $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)

}
elseif ((Get-Content -Path C:\temp\DB-tracking-log-old.txt | Where-Object {$_ -notin $new_file}) -ne $Null) {
      $body_diff = Get-Content -Path C:\temp\DB-tracking-log-old.txt | Where-Object {$_ -notin $new_file}
      $Body = "Database change alerts `nBefore: `n$body_old`nAfter: `n$body_new`nDiff: `n$body_diff" 
      $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}
Remove-Item -path "C:\temp\DB-tracking-log-old.txt"
Rename-Item -Path "C:\temp\DB-tracking-log.txt" -NewName "DB-tracking-log-old.txt"
