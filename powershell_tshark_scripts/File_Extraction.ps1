Measure-Command{
	$protocol = 'File_Extraction' #Update this
		new-item -path . -ItemType directory -name `_$protocol
		$OGpath = Get-Location
		$protocoldir = "$OGpath\`_$protocol"
		
	foreach($pcap in Get-ChildItem -path . -recurse | where{($_ -like ("*.pcapng") -or ($_ -like ("*.pcap")) -or ($_ -like ("*.cap")))}){
		#$path = Get-Location;
		$pcap2open = $pcap.fullname;
		Write-Output $pcap2open;
		Start-Process -FilePath 'C:\Program Files\Wireshark\tshark.exe' -ArgumentList "-nr `"$pcap2open`"","-Q","--export-objects dicom,`"$protocoldir\dicomobjects`"","--export-objects http,`"$protocoldir\httpobjects`"","--export-objects imf,`"$protocoldir\imfobjects`"","--export-objects smb,`"$protocoldir`\smbobjects`"","--export-objects tftp,`"$protocoldir\tftpobjects`"" -NoNewWindow -wait;
	} # KNOWN ISSUE: file names that are too long are not parsed by TSHARK

	New-item -itemtype directory -path $protocoldir -name "_UniqueFiles"
	$filedir = "$protocoldir`\_UniqueFiles"
	$myset = @{}
	foreach($hashes in gci -recurse -path $protocoldir | where-object {($_ -is [io.Fileinfo])} | Get-FileHash){
		$myset.add($hashes.path,$hashes.hash);
	}
	foreach($uniquehash in ($myset.GetEnumerator()|Sort-Object -Property value -Unique)){
		copy $uniquehash.key $filedir
	}
}