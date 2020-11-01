#WHEN UPDATING:
# 1. change protocol variable
# 2. Change Head variable
# 3. Change Start-Process -ArgumentList arguments

Measure-Command {
	$protocol = 'ARP' #Update this
	new-item -path . -ItemType directory -name `_$protocol
	$OGpath = Get-Location
	$protocoldir = "$OGpath\`_$protocol"
	#$path = Get-Location
	#$path = "$path\$protocol"
	New-Item -path $protocoldir -ItemType file -Name "body.txt"; 
	$head = '"arp.src.proto_ipv4","arp.src.hw_mac","arp.dst.proto_ipv4","arp.dst.hw_mac","arp.opcode"'; #Update Here! Leave the single quote (') surrounding the string
	$body = "$protocoldir\body.txt"; 	
	
	foreach($pcap in Get-ChildItem -path . -recurse | where{($_ -like ("*.pcapng") -or ($_ -like ("*.pcap")) -or ($_ -like ("*.cap")))}){
		#$path = Get-Location;
		$pcap2open = $pcap.fullname;
		Write-Output $pcap2open;
		Start-Process -FilePath 'C:\Program Files\Wireshark\tshark.exe' -ArgumentList "-r `"$pcap2open`"","-T fields","-Y arp","-e arp.src.proto_ipv4","-e arp.src.hw_mac","-e arp.dst.proto_ipv4","-e arp.dst.hw_mac","-e arp.opcode","-E separator=,","-E quote=d" -RedirectStandardOutput $body -NoNewWindow -wait; #update this
		$hashset = new-object System.Collections.Generic.HashSet[string]; 
		$reader = [system.io.file]::OpenText("$protocoldir\body.txt");
		try{
			while(($line = $reader.ReadLine()) -ne $null){
				$t = $hashset.Add($line)
			}
		} 
		finally{
			$reader.Close()
		} 
		$list = new-object system.collections.generic.List[string] $hashset; 
		$list.Sort(); 
		try{
			$pcapname = $pcap.basename
			$file = New-Object System.IO.StreamWriter "$protocoldir\$pcapname-streamsort.txt"; 
			foreach ($temp in $list){
				$file.WriteLine($temp)
			}
		}
		finally{
			$file.Close()
		}
	#Rename-Item $pcap "$pcap.processed"
	}
	$path = $OGpath
	$masterhashset = new-object System.Collections.Generic.HashSet[string];
	foreach($streamsort in Get-ChildItem -path $protocoldir *streamsort.txt){
		$masterreader = [system.io.file]::OpenText("$protocoldir\$streamsort");
			try{
				while(($masterline = $masterreader.ReadLine()) -ne $null){
					$t = $masterhashset.Add($masterline)
				}
			} 
			finally{
				$masterreader.Close()
			} 
	}
	$masterlist = new-object system.collections.generic.List[string] $masterhashset;
	$masterlist.Sort();
	try{ 
			$masterfile = New-Object System.IO.StreamWriter "$protocoldir\_$protocol`_unique_sorted.csv"; 
			$masterfile.WriteLine($head);
			foreach ($temp in $masterlist){
				$masterfile.WriteLine($temp)
			}
		}
		finally{
			$masterfile.Close()
		}
	Remove-Item -Path $protocoldir\body.txt
}