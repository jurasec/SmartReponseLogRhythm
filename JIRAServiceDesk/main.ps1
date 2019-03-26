# main.ps1
# Author Julio C. Rodriguez <jurasec@gmail.com>
# Date created 24/03/2019
# Description SmartResponse payload that creates a JIRA issue, the first param must be the AlarmID
# Note that some error handling, argument validation and other logic has been simplified or removed for this guide

[CmdletBinding()]

Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$alarmID,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$alarmRuleName
)

#### Issue tittle
$summary = $alarmRuleName + 'ID [' + $alarmID + ']'
$keyProject = 'LR'
#### $issueTypeId 1 = 'Incident'
$issueTypeId = '10001'

$issueType = @{
    id = $issueTypeId
}

$keyProject = @{
    key = $keyProject
}

#### Priorities Highest = 1, High= 2, Medium= 3, Low = 4, Lowest = 5
$priority = @{
    id = '1'
}

#### A random lable
$label = 'RBP80'

$labels = @(
    $label
)
$fields = @{
    project = $keyProject
    summary = $summary    
    issuetype = $issueType
    labels = $labels
    priority = $priority
}

$update = @{}

$jsonDoc = @{
    fields = $fields
    update = $update    
}

Write-Output $jsonDoc | ConvertTo-Json

$user = 'jurasec.logger@gmail.com'
$pass = 'atl190684'

$pair = "$($user):$($pass)"

Write-Verbose $pair

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$headers = @{
    Authorization = $basicAuthValue
}

$headers = @{ Authorization = $basicAuthValue }

Write-Verbose $basicAuthValue

$json = $jsonDoc | ConvertTo-Json
$response = Invoke-RestMethod -Uri 'https://logrhythm-sr-dev.atlassian.net/rest/api/3/issue' -Method 'POST' -Body $json -ContentType 'application/json' -Headers $headers
Write-Output $response
