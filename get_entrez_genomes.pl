#!/usr/bin/perl -w
use strict;

if (@ARGV < 1){die "USAGE: perl get_edirect.pl list.txt output.fas\n"};

##inputs
my $file = $ARGV[0] or die;
my $output = $ARGV[1] or die;

my $res;
my $acc;

open OUT, ">>$output";
open FILE, $file;
my $i = 1;
while(<FILE>){
	chomp;
	$acc = $_;
	$res = `esearch -db nucleotide -query $acc | efetch -format fasta`;
	print OUT $res;
	print "$i\n";
	$i++;
}
close OUT;
close FILE;
