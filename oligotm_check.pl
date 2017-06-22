#!/usr/bin/perl -w
use strict;

if (@ARGV < 1){die "USAGE: perl oligotm_chech.pl ids.txt primers.fas TMDIFFERENCE(optional)\n";}

## INPUT FILES
my $file_ids = $ARGV[0] or die;
my $file_primers = $ARGV[1] or die;

my (@primers, $pair);

`formatdb -i $file_primers -p F -o T`;

print "ID_F\tOLIGO_F\tTM_F\tID_R\tOLIGO_R\tTM_R\tTM_DIF\tSTATUS\n";
open IDS, $file_ids;
while (<IDS>){
	chomp;
	@primers = split(" ",$_);
	my @pf = split(/\n/,`fastacmd -s $primers[0] -d $file_primers | sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`);
	my @pr = split(/\n/,`fastacmd -s $primers[1] -d $file_primers | sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`);
	my $primerf = "";
	my $primerr = "";
	foreach (split //,$pf[1]){
		if ($_ eq "A" || $_ eq "T" || $_ eq "C" || $_ eq "G"){
		}else{
		$_ = "N"
		}
		$primerf .= $_;
	}

	foreach (split //,$pr[1]){
		if ($_ eq "A" || $_ eq "T" || $_ eq "C" || $_ eq "G"){
		}else{
		$_ = "N"
		}
		$primerr .= $_;
	}
	my $tpf = `oligotm -tp 1 -sc 1 $primerf`; chomp($tpf);
	my $tpr = `oligotm -tp 1 -sc 1 $primerr`; chomp($tpr);
	my $dif = $tpf-$tpr;

	my $threshold = $ARGV[2] // 5; ##DEFAULT MAXIMUM TEMPERATURE DIFFERENCE: 5
	my $status;
	if ($dif >= -$threshold && $dif <=$threshold) {
		$status = "GOOD"
	}else{
		$status = "BAD"
	}
	printf ("$primers[0]\t$pf[1]\t%.2f\t$primers[1]\t$pr[1]\t%.2f\t%.2f\t$status\n", $tpf,$tpr,abs($dif));
	
}
close IDS;

`mv formatdb.log files/`;
