#!/usr/bin/perl -w
use strict;


## INPUTS
if(@ARGV < 2){die "USAGE: perl search_pcr_mleprae.pl primers.fas database.fas MISMATCHES\nYou will also need a 'results' named folder.\n";}

my $primers_file = $ARGV[0] or die;
my $database_file = $ARGV[1] or die;
my $mismatches = $ARGV[2] or die;


## GLOBAL
my (@forwards, @reverses);


`formatdb -i $primers_file -p F -o T`; #formatdb
GetPrimerList();
RunPCR();


sub RunPCR{
	foreach my $pf (@forwards){
		foreach my $pr (@reverses){
			my $pair = "$pf-$pr";
			
			print "doing sample #$pair...\n";
			
			open PRIMERS, ">tmp.fas";
			print PRIMERS `fastacmd -s $pf -d $primers_file |  sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`;
			print PRIMERS `fastacmd -s $pr -d $primers_file |  sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`;
			close PRIMERS;
			
			`usearch -search_pcr $database_file -db tmp.fas -strand both -maxdiffs $mismatches -minamp 30 -maxamp 550 -ampout results/$pair.amplicons.fasta -log results/$pair.amplicons.log`;
		}
	}
}

sub GetPrimerList{
	open FILE, $primers_file;
	while (<FILE>){
		chomp;
		if(/^>/){
			if(/>(.*F.?)/){
				push @forwards, $1;
			}
			elsif(/>(.*R.?)/){
				push @reverses, $1;
			}
		}
	
	}
}

`rm formatdb.log tmp.fas`;
