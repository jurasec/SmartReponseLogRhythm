# LogRhythm SmartResponse Plugin for JIRA Service Desk integration: A basic guide.

The main target of this basic guide, is tho show how to developt a SmartResponse integrated with an external tool (JIRA).  This plugin is written in PowerShell.

## What does the SmartResponse plugin do?

When the SmartResponse is triggered, it takes the Alarm Id and Alarm Rule Name params and create an issue into the JIRA Service Desk, using a dedicated project to group all the LogRhyrhtm issues.

## Requirements:

1. Create a Jira Serice Desk account and create a new project. The new project is optional, it's just for a better ticket's organization.
2. A LogRhythm Enviroment to test and create the SmartResponse Plugin.
3. Your favorite Code Editor. 

## Steps.

1. Create a JIRA Service Desk user account.
2. Create a new JIRA project, and remember what **_key_** indentifies the new project, you will need it.  
![](/JIRAServiceDesk/images/JiraProjects.PNG)

The API URL that creates an issue is your **URL_home/rest/api/3/issue** via POST more info in this link https://developer.atlassian.com/cloud/jira/platform/rest/v3/#api-rest-api-3-issue-post.
My URL Home is https://logrhythm-sr-dev.atlassian.net

3. Plugin development.
   
  * Create the Payload. The payload consists of executables, scripts, and other supporting file types. The payload defines the actions that are taken by the SmartResponse after initiation. Our SmartResponse will only have one action, create an issue. The payload is very simple and Note that some error handling, argument validation and other logic has been simplified or removed for this guide.

```powershell
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
# key project
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

$user = 'your-email'
$pass = 'your-password'

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

```
  * Create the Configuration File. The configuration file indicates the input and output parameters of the SmartResponse Plugin and tells the SIEM how to activate the response. This plugin will take two params: the Alarm ID and Alarm Rule Name
```xml  
<?xml version="1.0" encoding="utf-8"?>
<remv1:Remediation-Plugin xmlns:remv1="RemediationVersion1.xsd" Name="JIRA Issues" Guid="00000000-0000-0000-0000-100000000000" Version="1" IsLogRhythmPlugin="false">
    <remv1:Action Name="Create an issue" Command="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe">
        <remv1:ConstantParameter Name="Script" Switch="-file main1.ps1" Order="1" />
        <remv1:StringParameter Name="AlarmId" Switch="" Order="2"> 
            <remv1:DefaultInput>
                <remv1:AlarmId  />
            </remv1:DefaultInput>
        </remv1:StringParameter>
        <remv1:StringParameter Name="AlarmRuleName" Switch="" Order="3"> 
            <remv1:DefaultInput>
                <remv1:AlarmRuleName  />
            </remv1:DefaultInput>
        </remv1:StringParameter>
    </remv1:Action>
</remv1:Remediation-Plugin>
```

4. Alarm Configuration. Open the tab configuration alarm desired and set the action named like JIRA Issue: **Create an issue**.
![](/JIRAServiceDesk/images/AlarmConf.PNG)

If all is ok. We will see an Smart Response successfully executed.

![](/JIRAServiceDesk/images/alarm.PNG)

The _inspector_ tab shows aditional execution output.

![](/JIRAServiceDesk/images/SmartResponseActions.PNG)

Now, JIRA should have all the issue created.

![](/JIRAServiceDesk/images/JiraIssues.PNG)

Issue details.

![](/JIRAServiceDesk/images/JIRAIssueDetails.PNG)

If you have any comments, feel free to contact me <jurasec@gmail.com>
