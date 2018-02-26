#Borrowed some UDP code from Boe Prox. Thanks Boe.
#https://learn-powershell.net/2011/02/21/querying-udp-ports-with-powershell/

function UDPee2 { #A Record resolution
[CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True,HelpMessage="Specify the A record to resolve")]
		[string]$ARecordName
	)
$ErrorActionPreference = 'Stop'
$enc = [system.Text.Encoding]::UTF8
$Str1 = $ARecordName.split('.') #Get rid of the .
$i = 0
ForEach ($Item in $Str1) {
New-Variable -Name Field$i -Value $enc.GetBytes($Str1[$i])
    [byte[]]$Middle += $(Get-Variable -Name Field$i | Select-Object -Expand Value).Length
    [byte[]]$Middle += $(Get-Variable -Name Field$i | Select-Object -expand Value)
$i++
}

#$udpobject.Client.Blocking = $False
$a = new-object system.text.asciiencoding

[byte[]]$Prepend = 0,4,1,0,0,1,0,0,0,0,0,0 #So, yeah. This needs to be broken out into separate variables for each piece of the DNS header. #First '4' is transaction ID - need to keep counter and ++
[byte[]]$Append = 0,0,1,0,1 #More header fields to be broken out - Record Type and Class (IN)

[byte[]]$Combined = $Prepend + $Middle + $Append
Write-Verbose $Combined
$udpobject = new-Object system.Net.Sockets.Udpclient
$udpobject.Connect("75.75.75.75",53)
$udpobject.Client.ReceiveTimeout = 1000

[void]$udpobject.Send($Combined,$Combined.length)
$remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0)

Try {
    $receivebytes = $udpobject.Receive([ref]$remoteendpoint)
} Catch {
    Write-Warning "$($Error[0])"
}

If ($receivebytes) {
$global:answer = $receivebytes
$String = $Answer[-4..-1] -join '.' #Lazy way. We capture the last 4 bytes and assume it's the IP. Gotta fix - but it works for now.
Write-Output $String
    #[string]$returndata = $a.GetString($receivebytes)
	#$returndata
} Else {
    "No data received from {0} on port {1}" -f $Computername,$Port
}
$udpobject.Close()

} #End UDPee2

function UDPeePTR { #PTR Record resolution
#[Byte[]]$byte = 0x00,0x09,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x39,0x39,0x02,0x31,0x30,0x03,0x31,0x36,0x39,0x03,0x31,0x39,0x32,0x07,0x69,0x6e,0x2d,0x61,0x64,0x64,0x72,0x04,0x61,0x72,0x70,0x61,0x00,0x00,0x0c,0x00,0x01 #99.10.169.192.in-addr.arpa 
$udpobject = new-Object system.Net.Sockets.Udpclient
$udpobject.Connect("172.31.252.100",53)
$udpobject.Client.ReceiveTimeout = 1000
#$udpobject.Client.Blocking = $False
#[Byte[]]$byte = 0x00,0x04,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x05,0x6f,0x63,0x68,0x69,0x6e,0x03,0x6f,0x72,0x67,0x00,0x00,0x01,0x00,0x01 #ochin.org
#[Byte[]]$byte = 0x00,0x04,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x65,0x62,0x61,0x79,0x03,0x63,0x6f,0x6d,0x00,0x00,0x01,0x00,0x01 #ebay.com
[Byte[]]$byte = 0x00,0x09,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x39,0x39,0x02,0x31,0x30,0x03,0x31,0x36,0x39,0x03,0x31,0x39,0x32,0x07,0x69,0x6e,0x2d,0x61,0x64,0x64,0x72,0x04,0x61,0x72,0x70,0x61,0x00,0x00,0x0c,0x00,0x01 #99.10.169.192.in-addr.arpa 
[void]$udpobject.Send($byte,$byte.length)
$remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0)

[Byte]$Query = 00-09-01-00-00-01-00-00-00-00-00-00-02-39-39-02-31-30-03-31-36-39-03-31-39-32-07-69-6e-2d-61-64-64-72-04-61-72-70-61-00-00-0c-00-01

Try {
   $receivebytes = [System.BitConverter]::ToString($udpobject.Receive([ref]$remoteendpoint))
} Catch {
    Write-Warning "$($Error[0])"
}

If ($receivebytes) {
$global:answer = $receivebytes
Write-Output $Answer
} Else {
    "No data received from {0} on port {1}" -f $Computername,$Port
}
$udpobject.Close()

} #End UDPeePTR

#$HexString = $Answer.Replace('-','')
$String = $Answer -split 'C0-0C-'
$HexString = $String[1].Replace('-',' ')

function HexToString($i) {
    $r = ""
    for ($n = 0; $n -lt $i.Length; $n += 2)
        {$r += [char][int]("0x" + $i.Substring($n,2))}
    return $r
    }
	
HexToString $HexString


$arr = [System.BitConverter]::ToString($Answer).split('-')