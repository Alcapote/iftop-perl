#!/usr/bin/perl

use strict;
use warnings;
use IO::File;


my $iIncre = 0;
my $iInterface_size;
my $down;
my $up;
my $display;
my $iFirstLoop = 0;
my @fields;
my @interface;
my @traffic;
my @traffic_save;


#Get all interfaces
open(rf_netdev, "/proc/net/dev") || die ("/!\\ Error, cannot open /proc/net/dev\n\n");

while(<rf_netdev>)
{
	@fields = split(':', $_);
	
	if($iIncre > 1)
	{
		$fields[0] =~  s/ //g;
		#if($fields[0] =~ /eth0/)
		#{
		$interface[$iIncre-2] = $fields[0];
		#}
	}

	$iIncre++;
}

close(rf_netdev);


#Put to 0 the table traffic_save
$iInterface_size = @interface;

for(my $i = 0; $i < $iInterface_size; $i++)
{
	$traffic_save[$i][0] = 0;
	$traffic_save[$i][1] = 0;
}


sub iftop
{
	my @arg_interface = shift;
	$iIncre = 0;

	open(rf_netdev, "/proc/net/dev") || die ("/!\\ Error, cannot open /proc/net/dev\n\n");
	while(<rf_netdev>)
	{
		if($iIncre > 1)
		{
			@fields = split(' ', $_);
			$traffic[$iIncre-2][0] = "".$fields[1]."";
			$traffic[$iIncre-2][1] = "".$fields[9]."";
			#print "".$fields[0]."          Down: ".$fields[1]." UP: ".$fields[9]."  \n";
		}
		
		$iIncre++;
	}
	close(rf_netdev);
}


#for(my $i = 0; $i < 5; $i++)
while(1)
{
	iftop(@interface);
	$display = "";
	
	for(my $j = 0; $j < $iInterface_size; $j++)
	{
		$down = $traffic[$j][0] - $traffic_save[$j][0];
		$up   = $traffic[$j][1] - $traffic_save[$j][1];
		$down = int($down / 128);
		$up   = int($up / 128);
		
		#@traffic_save = map { [@$_] } @traffic;
                $traffic_save[$j][0] = "".$traffic[$j][0]."";
                $traffic_save[$j][1] = "".$traffic[$j][1]."";

		#$display = "$display".$interface[$j]."  =>  $down ko/s     |     $up ko/s\n";

		if($iFirstLoop > 0)
		{
			print "".$interface[$j]."  =>  $down ko/s     |     $up ko/s\n";
			$up++;
		}
	}

	#print "$display";
	sleep 1;

	system("clear");
	#print "\n\n\n";
	$iFirstLoop++;
}

