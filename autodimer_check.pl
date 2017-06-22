#!/usr/bin/perl -w
use strict;

if (@ARGV < 1) {die "USAGE: perl autodimer_check.pl ids.txt primers.fas\nYou also need a folder named \"primers\" inside this dir.\n";}

## INPUT FILES
my $file_ids = $ARGV[0];
my $file_primers = $ARGV[1];

my @primers;

`formatdb -i $file_primers -p F -o T`;

open IDS, $file_ids;
while (<IDS>){
	chomp;
	@primers = split(" ",$_);
	my @pf = split(/\n/,`fastacmd -s $primers[0] -d files/primers.fas | sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`);
	my @pr = split(/\n/,`fastacmd -s $primers[1] -d files/primers.fas | sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`);
	my $temp = ">$primers[0]\n$pf[1]\n>$primers[1]\n$pr[1]\n";
	my $number = sprintf ("%02d_", $.);
	open ONEATTIME, ">primers/$number$primers[0]-$primers[1].fas";
	print ONEATTIME $temp;
	close ONEATTIME;
}
close IDS;

`rm formatdb.log`;
