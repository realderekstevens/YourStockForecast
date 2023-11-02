#!/usr/bin/bash

echo "Content-type: text/html"
echo ""

uptime=$(uptime -p)
mem=$(free -m | awk '{print $2, $3, $7}' | sed '2q;d')
load=$(awk '{print "<b>1</b>: " $1, "<b>5</b>: " $2, "<b>15</b>: " $3}' /proc/loadavg )

echo "<h3>Uptime</h3>"
echo "<p>$uptime</p>"
echo "<h3>Memory</h3>"
echo "<i>Total, Used, Available</i>"
echo "<p>"$mem"</p>"
echo "<h3>Load Average</h3>"
echo "<p> "$load" </p>"
