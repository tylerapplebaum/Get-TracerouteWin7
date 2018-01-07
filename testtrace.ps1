	$Target = "github.com"
	$TraceArr = @() #Store all RTT values per hop
	$SendICMP = New-Object System.Net.NetworkInformation.Ping
	$BufferData = "a" * $BufLen #Send the UTF-8 letter "a"
	$ByteArr = [Text.Encoding]::UTF8.GetBytes($BufferData)
	$PingOptions = New-Object System.Net.NetworkInformation.PingOptions
	$z = 1
  
	Do {
		$PingOptions.TTL = $z
		$ICMPResults = $SendICMP.Send($Target,1000,$ByteArr,$PingOptions)
		Write-Output $ICMPResults.Address.IPAddressToString
		Write-Output $ICMPResults.Status
		$TraceArr += $ICMPResults.Address.IPAddressToString
		$z++
		Write-Host $z
	}
	Until ($ICMPResults.Status -eq "Success")
  
  Write-Output $TraceArr
  
  # PTR Record Lookup
  
  [Net.DNS]::Resolve("192.169.10.99") | Select -ExpandProperty HostName
  $Hop = "67.51.253.126"
  Try {
  $Test = [Net.DNS]::GetHostEntry($Hop) | Select -ExpandProperty HostName
  }
  Catch [System.Management.Automation.MethodInvocationException] {
  Write-Output "Shit's broke, yo!"
  }

Function script:Invoke-ResolveDNS {

}  

Function script:Resolve-DNS {

[CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline=$True)]
    [Int]$Timeout = 4
  )

$ResolveDNSSource = @"
//https://web.archive.org/web/20110207162807/http://www.codekeep.net/snippets/de6ba175-0dad-41e3-8f8f-9d652572329c.aspx
using System;
using System.Net;

public class ResolveDNS {

	public delegate IPHostEntry GetHostEntryHandler(string ip);
	public string ReverseDNS(string ip, int timeout)
	{
		try
		{
			GetHostEntryHandler callback = new GetHostEntryHandler(Dns.GetHostEntry);
			IAsyncResult result = callback.BeginInvoke(ip, null, null);
			if (result.AsyncWaitHandle.WaitOne(timeout * 1000, false))
			{
				// Received response within timeout limit
				return callback.EndInvoke(result).HostName;
			}
			else
			{
				// Did not receive response within timeout limit, 
				// send back IP Address instead of hostname
				return ip;
			}
		}
		catch (Exception)
		{
			// Error occurred, send back IP Address instead of hostname
			return ip;
		}
	}

}

"@

Add-Type -TypeDefinition $ResolveDNSSource

$Resolver = New-Object ResolveDNS

  If ($Hop -notlike "TimedOut" -and $Hop -notlike "0.0.0.0") {
	$z++ #Increment the count for the progress bar
	Write-Progress -Activity "Resolving PTR Record" -Status "Looking up $Hop, Hop #$z of $($TraceResults.length)" -PercentComplete ($z / $($TraceResults.length)*100)
	$HopName = $Resolver.ReverseDNS($Hop,$Timeout)
	Write-Verbose "HopName = $HopName"
	Write-Verbose "Hop = $Hop"
  }

  Else {
    $z++
    $HopName = $Hop #If the hop times out, set name equal to TimedOut
    Write-Verbose "Hop = $Hop"
  }
} #End Resolve-DNS
<#
    If ($HopNameArr.NameHost -AND $HopNameArr.NameHost.GetType().IsArray) { #Check for array first; sometimes resolvers are stupid and return NS records with the PTR in an array.
      $script:HopName | Add-Member -MemberType NoteProperty -Name NameHost -Value $HopNameArr.NameHost[0] #If Resolve-DNS brings back an array containing NS records, select just the PTR
      Write-Verbose "Object found $HopName"
    }

    ElseIf ($HopNameArr.NameHost -AND $HopNameArr.NameHost.GetType().FullName -like "System.String") { #Normal case. One PTR record. Will break up an array of multiple PTRs separated with a comma.
      $script:HopName | Add-Member -MemberType NoteProperty -Name NameHost -Value $HopNameArr.NameHost.Split(',')[0].Trim() #In the case of multiple PTRs select the first one
      Write-Verbose "String found $HopName"
    }

    ElseIf ($HopNameArr.NameHost -like $null) { #Check for null last because when an array is returned with PTR and NS records, it contains null values.
      $script:HopName | Add-Member -MemberType NoteProperty -Name NameHost -Value $Hop #If there's no PTR record, set name equal to IP
      Write-Verbose "HopNameArr apparently empty for $HopName"
    }
    
  }
  
  
  Return $HopNameArr
  #>
} #End Resolve-DNS