#!/usr/bin/perl -w
use strict;


if (@ARGV < 2){die "USAGE: perl run_gen_errors.pl PATHtoSOURCE FILESNAMES TIMES\n"};

my $path = $ARGV[0];
my $names = $ARGV[1];
my $times = $ARGV[2];


open NAMES, $names;
while(<NAMES>){
	print "Generating file $_";
	chomp;
	`perl gen_errors.pl $path$_ $times > /storage/Data/db/leprae/results/ano2/07_bench2/fasta/$_`;
}
close NAMES;
