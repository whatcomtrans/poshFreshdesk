#private functions

#public cmdlets

<#
.SYNOPSIS
TODO:

.DESCRIPTION
TODO:

.PARAMETER FixCommand
TODO:

.PARAMETER FixCommandString
A String that can be converted to a ScriptBlock to be added to that fix that will be executed to fix the issue.

.PARAMETER FixDescription
A user friendly description of what the fix does, prefereble specific to this instance.

.PARAMETER CheckName
Name of the issue check that generated this fix.

.PARAMETER Status
The status of this fix.  See IssueFixStatus enum.  Default is Ready.

.PARAMETER NotificationCount
Set the number of times notices is sent about this fix.  Usefull for scheduled notifications of pending fixes.  Each time a notificaton is sent for a fix the notificationCount is decremented by one. By default, only fixes with a notification count greater then 0 are sent. This allows for control over how often a fix is notified about.  Default is 10000.

.PARAMETER SequenceNumber
Fix sort order.  Default is 1.

.PARAMETER ScheduledAfter
DateTime (defaults to current) in which the fix is able to be invoked when status is also Scheduled

.PARAMETER Priority
Priority High, Meduim or Low.  Defaults to Low.

.PARAMETER useCommandAsDescription
Switch to ignore the passed description, if any, and instead use the command as a string value for description.

.INPUTS
TODO: 

.OUTPUTS
A Contact object

#>
function Get-FdContact {
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType("poshFreshDesk.Contact")]
	Param(
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $Id,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $email,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $mobile,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $phone,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $company_id,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $state,  #TODO: Add validated list: blocked/deleted/unverified/verified
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [DateTime] $updated_since,
        [Parameter(Mandatory=$false)]
            [Int] $page,
        [Parameter(Mandatory=$false)]
            [Int] $per_page,
        [Parameter(Mandatory=$false)]
            [String] $Query,
        [Parameter(Mandatory=$true)]
            [String] $Domain,
        [Parameter(Mandatory=$true)]
            [String] $APIKey
    )

    Begin {
        # https://zoomcloud.blogspot.com/2016/12/freshdesk-statusboard-powershell.html
        # Part one script starts here

        # Force TLS1.2 as Powershell defaults to TLS 1.0 and Freshdesk will fail connections
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

        # Prep
        $pair = "$($ApiKey):$($ApiKey)"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $basicAuthValue = "Basic $base64"
        $FDHeaders = @{ Authorization = $basicAuthValue }
        ##################################################
        
    }

    Process {
        $url = "https://$($Domain).freshdesk.com/api/v2"

        if ($Id) {
            $url = "$($url)/contacts/$id"
        } elseif ($state) {
            $url = "$($url)/contacts?state=$state"
        } elseif ($company_id) {
            $url = "$($url)/contacts?company_id=$company_id"
        #TODO: add rest of filter parameters
        } elseif ($Filter) {
            $url = "$($url)/contacts?query=$('"')$([System.Web.HTTPUtility]::UrlEncode($Query))$('"')"
        } else {
            $url = "$($url)/contacts"
        }

        if ($page) {
            if ($url.IndexOf('?') -gt 0) {
                $url = "$($url)&page=$page"
            } else {
                $url = "$($url)?page=$page"
            }
        }

        if ($per_page) {
            if ($url.IndexOf('?') -gt 0) {
                $url = "$($url)&per_page=$per_page"
            } else {
                $url = "$($url)?per_page=$per_page"
            }
        }
        Invoke-RestMethod -Method GET -Uri $url -Headers $FDHeaders -ContentType "application/json" | Write-Output
    }
}

function New-FdContact {
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType("poshFreshDesk.Contact")]
	Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
            [String] $name,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [string] $email,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $phone,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $mobile,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $twitter_id,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $unique_external_id,  #See https://support.freshdesk.com/support/solutions/articles/226804-identifying-contacts-with-an-external-id for supported Plans
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String[]] $other_emails,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [long] $company_id,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [bool] $view_all_tickets = $false,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [long[]] $other_companies,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $address,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [PSObject] $avatar,  #TODO: this will not be initiall supported...
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [hashtable] $custom_fields,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $description,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $job_title,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $language,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String[]] $tags,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $time_zone,
        [Parameter(Mandatory=$true)]
            [String] $Domain,
        [Parameter(Mandatory=$true)]
            [String] $APIKey
    )

    Begin {
        # https://zoomcloud.blogspot.com/2016/12/freshdesk-statusboard-powershell.html
        # Part one script starts here

        # Force TLS1.2 as Powershell defaults to TLS 1.0 and Freshdesk will fail connections
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

        # Prep
        $pair = "$($ApiKey):$($ApiKey)"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $basicAuthValue = "Basic $base64"
        $FDHeaders = @{ Authorization = $basicAuthValue }
        ##################################################
        

        $toInclude = @("name","email","phone","mobile","twitter_id","unique_external_id","other_emails","company_id","view_all_tickets","other_companies", "address","description","job_title","language", "tags", "time_zone", "custom_fields")
    }

    Process {
        $url = "https://$($Domain).freshdesk.com/api/v2"

        #Validate that one of the 4 mandatory fields is set
        $validated = $false
        if ($PSBoundParameters.ContainsKey("email")) { $validated = $true }
        if ($PSBoundParameters.ContainsKey("phone")) { $validated = $true }
        if ($PSBoundParameters.ContainsKey("mobile")) { $validated = $true }
        if ($PSBoundParameters.ContainsKey("twitter_id")) { $validated = $true }
        if ($PSBoundParameters.ContainsKey("unique_external_id")) { $validated = $true }
        
        if ($validated) {
            #Create body object
            [hashtable] $bodyHT = @{}
            
            forEach ($key in $PSBoundParameters.Keys) {
                if ($key -in $toInclude) {
                    $bodyHT.Add($key, $PSBoundParameters[$key])
                }
            }

            $body = ConvertTo-Json -InputObject $bodyHT -Depth 100

            #URL
            $url = "$($url)/contacts"

            #Submit
            Write-Verbose $body
            Invoke-RestMethod -Method POST -Uri $url -Headers $FDHeaders -ContentType "application/json" -Body $Body | Write-Output
        } else {
            Write-Error -Message "Missing a mandatory parameter, see API documentation."
        }
    }
}

function Set-FdContact {
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType("poshFreshDesk.Contact")]
	Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
            [String] $id,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $name,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [string] $email,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $phone,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $mobile,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $twitter_id,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $unique_external_id,  #See https://support.freshdesk.com/support/solutions/articles/226804-identifying-contacts-with-an-external-id for supported Plans
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String[]] $other_emails,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [long] $company_id,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [bool] $view_all_tickets = $false,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [long[]] $other_companies,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $address,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [PSObject] $avatar,  #TODO: this will not be initiall supported...
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [hashtable] $custom_fields,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $description,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $job_title,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $language,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String[]] $tags,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [String] $time_zone,
        [Parameter(Mandatory=$true)]
            [String] $Domain,
        [Parameter(Mandatory=$true)]
            [String] $APIKey
    )

    Begin {
        # https://zoomcloud.blogspot.com/2016/12/freshdesk-statusboard-powershell.html
        # Part one script starts here

        # Force TLS1.2 as Powershell defaults to TLS 1.0 and Freshdesk will fail connections
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

        # Prep
        $pair = "$($ApiKey):$($ApiKey)"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $basicAuthValue = "Basic $base64"
        $FDHeaders = @{ Authorization = $basicAuthValue }
        ##################################################
        

        $toInclude = @("name","email","phone","mobile","twitter_id","unique_external_id","other_emails","company_id","view_all_tickets","other_companies", "address","description","job_title","language", "tags", "time_zone", "custom_fields")
    }

    Process {
        $url = "https://$($Domain).freshdesk.com/api/v2"

        # Create body object
        [hashtable] $bodyHT = @{}
        
        forEach ($key in $PSBoundParameters.Keys) {
            if ($key -in $toInclude) {
                $bodyHT.Add($key, $PSBoundParameters[$key])
            }
        }

        $body = ConvertTo-Json -InputObject $bodyHT -Depth 100

        #URL
        $url = "$($url)/contacts/$($id)"

        #Submit
        Write-Verbose $body
        Invoke-RestMethod -Method PUT -Uri $url -Headers $FDHeaders -ContentType "application/json" -Body $body | Write-Output
    }
}
function Get-FdContactFields {
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType("poshFreshDesk.Contact")]
	Param(
        [Parameter(Mandatory=$true)]
            [String] $Domain,
        [Parameter(Mandatory=$true)]
            [String] $APIKey
    )

    Begin {
        # https://zoomcloud.blogspot.com/2016/12/freshdesk-statusboard-powershell.html
        # Part one script starts here

        # Force TLS1.2 as Powershell defaults to TLS 1.0 and Freshdesk will fail connections
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

        # Prep
        $pair = "$($ApiKey):$($ApiKey)"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $basicAuthValue = "Basic $base64"
        $FDHeaders = @{ Authorization = $basicAuthValue }
        ##################################################
        
    }

    Process {
        $url = "https://$($Domain).freshdesk.com/api/v2"

        Invoke-RestMethod -Method GET -Uri "$($url)/contact_fields" -Headers $FDHeaders -ContentType "application/json" | Write-Output
    }
}

function Remove-FdContact {
    [CmdletBinding(SupportsShouldProcess=$false)]
    #TODO: [OutputType("poshFreshDesk.Contact")]
	Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
            [String] $Id,
        [Parameter(Mandatory=$false)]
            [switch] $hard_delete,
        [Parameter(Mandatory=$false)]
            [switch] $force_hard_delete,
        [Parameter(Mandatory=$true)]
            [String] $Domain,
        [Parameter(Mandatory=$true)]
            [String] $APIKey
    )

    Begin {
        # https://zoomcloud.blogspot.com/2016/12/freshdesk-statusboard-powershell.html
        # Part one script starts here

        # Force TLS1.2 as Powershell defaults to TLS 1.0 and Freshdesk will fail connections
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

        # Prep
        $pair = "$($ApiKey):$($ApiKey)"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $basicAuthValue = "Basic $base64"
        $FDHeaders = @{ Authorization = $basicAuthValue }
        ##################################################
        
    }

    Process {
        $url = "https://$($Domain).freshdesk.com/api/v2"

        $url = "$($url)/contacts/$($id)"
        if ($hard_delete) {
            $url = "$($url)/hard_delete"
            if ($force_hard_delete) {
                $url = "$($url)?force=true"
            }
        }
        $result = Invoke-WebRequest -Method DELETE -Uri "$($url)" -Headers $FDHeaders -ContentType "application/json"
        switch ($result.StatusCode) {
            204 { Write-Output "Success"}
            400 { Write-Output "User invalid (not soft deleted)"}
            404 { Write-Output "User not found"}
        }
    }
}
