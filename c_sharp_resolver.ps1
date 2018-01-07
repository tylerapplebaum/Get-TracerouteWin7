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
$Resolver.ReverseDNS("192.169.11.4",5)


$T = (New-Object ResolveDNS).ReverseDNS("8.8.4.4",2)

