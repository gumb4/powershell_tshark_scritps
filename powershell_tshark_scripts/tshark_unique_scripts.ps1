#in order to run this script, execute the script with the following:
# Set-Executionpolicy -executionpolicy bypass -scope currentuser; .\tshark_unique_scripts.ps1

foreach($script in gci -filter "*.ps1"){
echo "The current running script is: $script";
$measure = Measure-Command{& .\$script;}
echo "The $script took $measure.minutes"
$runningmeasure = $runningmeasure + $measure
echo "The total running time is: $runningmeasure"`n
}
