#Author - Munishpal Makhija

#    ===========================================================================
#    Created by:    Munishpal Makhija
#    Release Date:  02/28/2020
#    Organization:  VMware
#    Version:       1.0
#    Blog:          http://bit.ly/MyvBl0g
#    Twitter:       @munishpal_singh
#    ===========================================================================

####################### Use Case #########################

######	Generate an HTML Report for Deployments in vRA Cloud Environment / Org

######	It displays following details 

######	Deployment Summary - Number of deployments per Project
######	Deployments Details - List all deployments per Project and list details such as projectid , name , id, createdBy, createAt, Status
######	Deployment Resources - For each successfull deployment display resource for e.g. One deployment can have Cloud Machine, Cloud Network 


####################### Pre-requisites #########################

######	1 - PowervRACloud Version 1.1 
######	2 - Connected to vRA Cloud using Connect-vRA-Cloud -APIToken $APIToken


####################### Usage #########################

######	Download the script and save it to a Folder and execute ./vRACloudDeploymentsReport.ps1



####################### Dont Modify anything below this line #########################



$Header = @"
<style>
body { background-color:#E5E4E2;
       font-family:sans-serif;
       font-size:10pt; }
td, th { border:0px solid black; 
         border-collapse:collapse;
         white-space:pre; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px ;white-space:pre; }
tr:nth-child(odd) {background-color: lightgray}
table { width:95%;margin-left:5px; margin-bottom:20px;}
h1 {
 font-family:sans-serif;
 color:#008000;
}
h2 {
 font-family:sans-serif;
 color:#0000A0;
}
h3 {
 font-family:sans-serif;
 color:#0000FF;
}
.alert {
 color: red; 
 }
.footer 
{ color:green; 
  margin-left:10px; 
  font-family:sans-serif;
  font-size:8pt;
  font-style:italic;
}
</style>
"@


$html = @()
$deployments = @()
$deploymentresources = @()
$summary = @()
$deploymentname = @()
$date = Get-Date
$user = whoami

$deployments = Get-vRA-DeploymentFilters -filterId "projects" | Sort-Object Count -Descending 
$html += $deployments | select name,id,count | ConvertTo-Html -As Table -Fragment -PreContent "<h1> Deployment Summary</h1>" 

$projects = $deployments | select id,name


ForEach ($project in $projects)
{
	$projectname = $project.name
	$projectid = $project.id
	$group = $project.Group
	$deployments = Get-vRA-Deployments | where {$_.project.id -eq $projectid}
				if ($deployments)
			{
				$html += $deployments | select {$_.project.id},{$_.project.name},name,id,createdBy,createdAt,Status | ConvertTo-Html -As Table -Fragment -PreContent "<h2> Project Name - $projectname | Project ID - $projectid </h2>"
				ForEach ($deployment in $deployments)
				{
				$status = $deployment.status
				if ($status –eq "CREATE_SUCCESSFUL")
				{
				$deploymentname = $deployment.name
				$deploymentresources = Get-vRA-DeploymentResources -DeploymentName $deploymentname | Select name,id,type
				$html += $deploymentresources | ConvertTo-Html -As Table -Fragment -PreContent "<h3> Deployment Name - $deploymentname </h3>"
				}	
				}
			}		
}

$html += "<br><i> <center> Run by $user at $date  </center> </i>"
$html += "<br><i> <center> Generated using <a href=https://flings.vmware.com/power-vra-cloud> Power vRA Cloud </a></center> </i>"
$html += "<br><i> <center> Author - <a href=https://www.linkedin.com/in/munishpal-makhija-7139515> Munishpal Makhija </a></center> </i>"

$prefix = (Get-Date).ToString(‘M-d-y’)
$filename = "vRA Cloud Deployment Report -"+ $prefix+ ".html"
ConvertTo-Html -Body "$html" -Title "vRA Cloud Report" -Head $header| Out-File $filename
$directory = pwd
$file = "$directory/$filename"


####################### End of File #########################