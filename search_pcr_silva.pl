#!/usr/bin/perl -w
use strict;


## INPUTS
if(@ARGV < 3){die "USAGE: perl auto_searchpcr.pl ids.txt primers.fas database.fas MISMATCHES\nYou will also need a 'results' named folder.\n";}

my $ids_file = $ARGV[0] or die;
my $primers_file = $ARGV[1] or die;
my $database_file = $ARGV[2] or die;
my $mismatches = $ARGV[3] or die;


`formatdb -i $primers_file -p F -o T`; #formatdb
RunPCR();

sub RunPCR{
        open IDS, $ids_file;
        while (<IDS>){
		chomp;
		my ($id, $pf, $pr) = split(/\./, $_);

		my $pair = "$pf-$pr";
		print "doing sample #$pair...\n";
		
		open PRIMERS, ">tmp.fas";
		print PRIMERS `fastacmd -s $pf -d $primers_file |  sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`;
		print PRIMERS `fastacmd -s $pr -d $primers_file |  sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`;
		close PRIMERS;
			
			`usearch -search_pcr $database_file -db tmp.fas -strand both -maxdiffs $mismatches -minamp 30 -maxamp 550 -ampout results/$pair.amplicons.fasta -log results/$pair.amplicons.log`;
	}

close IDS;
}

`rm formatdb.log tmp.fas`;
