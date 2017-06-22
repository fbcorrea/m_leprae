#!/usr/bin/perl -w
use strict;


## INPUTS
if(@ARGV < 3){die "USAGE: perl auto_searchpcr.pl ref.txt primers.fas genomes.fas MISMATCHES\nYou will also need a 'amplicons' named folder.\n";}

my $ids_file = $ARGV[0] or die;
my $primers_file = $ARGV[1] or die;
my $database_file = $ARGV[2] or die;
my $mismatches = $ARGV[3] or die;

## ACTIONS
`formatdb -i $primers_file -p F -o T`;
RunPCR();

sub RunPCR{
        open IDS, $ids_file;
        while (<IDS>){
		chomp;
		my ($id, $pf, $pr, $len) = split(/\t/, $_);
		my $min = $len - 10;
		my $max = $len + 10;

		my $pair = "$pf-$pr";
		print "doing sample #$pair...\n";
#print "$min\t$max\n";
		open PRIMERS, ">tmp.fas";
		print PRIMERS `fastacmd -s $pf -d $primers_file |  sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`;
		print PRIMERS `fastacmd -s $pr -d $primers_file |  sed -r -e 's/>lcl\\|/>/' | sed -r -e 's/\\s\.+//'`;
		close PRIMERS;
		
		`usearch -search_pcr $database_file -db tmp.fas -strand both -maxdiffs $mismatches -minamp $min -maxamp $max -ampout amplicons/$pair.amplicons.fasta -log amplicons/$pair.amplicons.log 2>> errors`;
	}
close IDS;
}

`rm formatdb.log tmp.fas`;
