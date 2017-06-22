#!/usr/bin/perl -w
use strict;

my $file = $ARGV[0] or die "USAGE: perl parse_table_for_r.pl table-ex.txt\n";

my @fields;

open TABLE, $file;
while(<TABLE>){
	chomp;
	my @fields_temp = split(",",$_);
	for (my $i=0; $i < scalar(@fields_temp); $i++){
		$fields[$i] .= "$fields_temp[$i]\t";
	}
}

print join("\n", @fields);
