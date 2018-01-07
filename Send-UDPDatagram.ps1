function Send-Datagram {
    [CmdletBinding()]
    param(
      [parameter(Mandatory=$true)][string] $data,
      [parameter(Mandatory=$false)][string] $address="127.0.0.1",  
      [parameter(Mandatory=$false)][int] $port=53
    )
<#
    $ipAddress = $null
    $parseResult = [System.Net.IPAddress]::TryParse($address, [ref] $ipAddress)

    if ( $parseResult -eq $false ) 
    {
        $addresses = [System.Net.Dns]::GetHostAddresses($address)
        
        if ( $addresses -eq $null ) 
        {
            throw "Unable to resolve address: $address"
        }

        $ipAddress = $addresses[0]
    }    
#>
    $endpoint = New-Object System.Net.IPEndPoint($ipAddress, $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient
	$udpClient.Connect($address,$port)
    $encodedData=[System.Text.Encoding]::ASCII.GetBytes($data)
    $bytesSent=$udpClient.Send($encodedData,$encodedData.length,$endpoint)

    $udpClient.Close()
}

function Send-DNSDatagram { #Shit works son!!!!!
    [CmdletBinding()]
    param(
      [parameter(Mandatory=$false)][string] $data,
      [parameter(Mandatory=$false)][string] $address="172.31.252.100",  
      [parameter(Mandatory=$false)][int] $port=53
    )

	#[Byte[]]$data = 0x00,0x04,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x05,0x6f,0x63,0x68,0x69,0x6e,0x03,0x6f,0x72,0x67,0x00,0x00,0x01,0x00,0x01
	
    $endpoint = New-Object System.Net.IPEndPoint($Address, $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient
	$udpClient.Connect($address,$port)
    $encodedData=[System.Text.Encoding]::ASCII.GetBytes($data)
    #[Byte[]]$encodedData = 0x00,0x04,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x05,0x6f,0x63,0x68,0x69,0x6e,0x03,0x6f,0x72,0x67,0x00,0x00,0x01,0x00,0x01 #ochin.org
    [Byte[]]$encodedData = 0x00,0x04,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x65,0x62,0x61,0x79,0x03,0x63,0x6f,0x6d,0x00,0x00,0x01,0x00,0x01 #ebay.com
    #$encodedData='000401000001000000000000056f6368696e036f72670000010001'
    $bytesSent=$udpClient.Send($encodedData,$encodedData.length,$endpoint)
#new below here
	$receivebytes = $udpclient.Receive([ref]$endpoint)
	
	[string]$returndata = $a.GetString($receivebytes)
    $returndata
	
	pause
#end new code for receive
    $udpClient.Close()
}