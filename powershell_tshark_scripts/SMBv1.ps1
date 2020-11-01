#WHEN UPDATING:
# 1. change protocol variable
# 2. Change Head variable
# 3. Change Start-Process -ArgumentList arguments

Measure-Command {
	$protocol = 'SMBv1' #Update this
	new-item -path . -ItemType directory -name `_$protocol
	$OGpath = Get-Location
	$protocoldir = "$OGpath\`_$protocol"
	#$path = Get-Location
	#$path = "$path\$protocol"
	New-Item -path $protocoldir -ItemType file -Name "body.txt"; 
	$head = '"eth.src","ip.src","eth.dst","ip.dst","smb.cmd","smb.trans_name","smb.account","smb.password","smb.path","smb.service","smb.native_os","smb.dir_name","smb.file","browser.mb_server","browser.server","browser.windows_version","browser.os_major","browser.os_minor","browser.comment"'; #Update Here! Leave the single quote (') surrounding the string
	$body = "$protocoldir\body.txt"; 	
	
	foreach($pcap in Get-ChildItem -path . -recurse | where{($_ -like ("*.pcapng") -or ($_ -like ("*.pcap")) -or ($_ -like ("*.cap")))}){
		#$path = Get-Location;
		$pcap2open = $pcap.fullname;
		Write-Output $pcap2open;
		Start-Process -FilePath 'C:\Program Files\Wireshark\tshark.exe' -ArgumentList "-r `"$pcap2open`"","-T fields","-Y smb","-e eth.src","-e ip.src","-e eth.dst","-e ip.dst","-e smb.cmd","-e smb.trans_name","-e smb.account","-e smb.password","-e smb.path","-e smb.service","-e smb.native_os","-e smb.dir_name","-e smb.file","-e browser.mb_server","-e browser.server","-e browser.windows_version","-e browser.os_major","-e browser.os_minor","-e browser.comment","-E separator=,","-E quote=d" -RedirectStandardOutput $body -NoNewWindow -wait; #update this
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