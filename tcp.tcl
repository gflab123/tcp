set ns [new Simulator]

set nf [open tcp.nam w]
set tr [open tcp.tr w]

$ns namtrace-all $nf 
$ns trace-all $tr

proc finish {} {
	global ns nf tr
	$ns flush-trace
	close $tr
	exec nam tcp.nam &
	exit 0
}

for {set i 0} {$i < 4} {incr i} {
	set n($i) [$ns node]
}

$ns duplex-link $n(0) $n(1) 10Mb 10ms DropTail
$ns duplex-link $n(1) $n(3) 10Mb 10ms DropTail
$ns duplex-link $n(2) $n(1) 10Mb 10ms DropTail

$ns duplex-link-op $n(0) $n(1) orient right-down
$ns duplex-link-op $n(1) $n(3) orient right
$ns duplex-link-op $n(2) $n(1) orient right-up

set tcp [new Agent/TCP]
$ns attach-agent $n(0) $tcp

set ftp [new Application/FTP]
$ftp attach-agent $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n(3) $sink

set udp [new Agent/UDP]
$ns attach-agent $n(2) $udp

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp

set null [new Agent/Null]
$ns attach-agent $n(3) $null

$ns connect $tcp $sink
$ns connect $udp $null

$ns rtmodel-at 1.0 down $n(1) $n(3)
$ns rtmodel-at 2.0 up $n(1) $n(3)
$ns rtproto DV

$ns at 0.0 "$ftp start"
$ns at 0.0 "$cbr start"
$ns at 5.0 "finish"

$ns run
