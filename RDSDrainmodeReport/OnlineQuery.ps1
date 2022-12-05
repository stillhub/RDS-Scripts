
<#
    This script will scan connection status of RDS Servers and send an email if New Connections are disabled.
    Author: Jared Stillwell
    Last Edit: 2020-11-09
    Version 1.0 - initial release.

    Notes:
    - Add to task scheduler.
    - Script will only alert once a day.
    -
    Future releases:
    -
#>

#Checks if drain-mode alert has been sent in the last 24 hours, will not continue.
function PreviousLogDate {
    $PreviousLog = Get-Content -Path $DrainDateLog
    if($LogDate -ge $PreviousLog){
        CheckRDSHost
    }else {
        #Exit program
    }
}

#Checks RDS server for server not allowing connections. Calls SendPostEmail function if a RDS server condition is true.
function CheckRDSHost {
    $NextRunDate = (Get-Date).AddDays(1).ToString('yyyy-MM-dd')
    $global:RDSConnections = Get-RDSessionHost -CollectionName "RDS Applications" -ConnectionBroker RDS.x.local
    $RDSConnectionsString = $RDSConnections | Out-String
    $drainmode = $RDSConnectionsString -Match 'No'
    if($drainmode){
        $NextRunDate | Out-File $DrainDateLog -Encoding UTF8
        SendPostEmail
    }else{
        #Exit program
    }
}

#This function sends a detailed email.
function SendPostEmail {
    $smtp = "smtp.x.local"
    $to = "x@example.com"
    $from = "ServiceDesk <ServiceDesk@example.com>"
    $CC = "support@example.com"
    $subject = "RDS Host Offline - $LogDate"
    $body = "Hi Team,<br>"
    $body += "<br>"
    $body += "<br>"
    $body += "<br>"
    $body += "RDS Server is currently in drain mode. Time checked: $LogDate.<br>"
    $body += "<br>"
    $body += $global:RDSConnections | ConvertTo-Html
    $body += "<br>"
    $body += "<br>"
    $body += "Regards<br>"
    $body += "<br>"
    $body += "Service Desk<br>"
    $body += "<br>"
    $body += "<br>"
    $body += "<br>"
    Send-MailMessage -SmtpServer $smtp -To $to -CC $cc -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high
}

$DrainDateLog = ".\PreviousLogDate.log"
$LogDate = Get-Date -Format yyyy-MM-dd

PreviousLogDate