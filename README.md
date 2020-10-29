# powershell_tshark_scritps
Powershell tsahrk scripts to help with large scale pcap analysis

This came around due to being handed 40Gb of pcap to analyze in a week with only tool preovided being wireshark. My goal was to get an overview of common protocols fields for that large of a set of pcaps without having to use the Wireshark GUI. 

Instructions
0. (situational) use cmd <"C:\Program Files\Wireshark\tshark.exe" -r <input pcap> -w <output pcap naming scheme> -C 100> if pcap are individually large to split it into 100mb files.
1. Place powershell scripts in same directory as pcaps to analyze.
2a. To run all scripts at once, run the powershell command: Set-Executionpolicy -executionpolicy bypass -scope currentuser; .\tshark_unique_scripts.ps1
2b. To run individual powershell scripts, run the powershell command: Set-Executionpolicy -executionpolicy bypass -scope currentuser; .\<script you want to run>.ps1
3. Analyze results.

Notes
A. The scripts will create directories with CSV of unique results. Also in the created folder will be a txt document for each individual pcap results that can be loaded into excel to help guide more taylored analysis.
B. File_Extraction.ps1 is an exception and creates directories
C. Many cells in the csv will have multiple values in them.
D. This will only give unique rows based off fields except where noted.
E. LLDP-port id excel likes to be formatted as date instead.
F. Ip-note first instance only in th packet
G. MAC-note first instance only in the packet
H. Telnet-normally has messed up format in excel-double check by opening it up in a text viewer
I. Additional fields of interest can be added easily but need to be exact can use https://www.wireshark.org/docs/dfref/ to find fields.
J. Made for TShark (Wireshark) 3.2.7 (v3.2.7-0-gfb6522d84a3a)

Credit to Ross, Nick and Christian
