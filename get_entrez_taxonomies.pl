#!/usr/bin/perl -w
use strict;

if (@ARGV < 1){die "USAGE: perl get_entrez_taxonomies.pl accessions.txt output.txt\n"};

my $ids = $ARGV[0] or die;
my $output = $ARGV[1] or die;

open FILE, $ids;
open OUT, ">>$output";

while(<FILE>){
	chomp;
	
	my $esearch = `esearch -db nucleotide -query $_ | efetch -format gb`;
	my @lines = split("\n",$esearch);
		foreach my $a (@lines){
			my $taxon;
			if ($a =~ /\/db_xref="taxon:(\d+)"/){
				$taxon = $1;
				my $rank = `efetch -db taxonomy -id $taxon -format xml | xtract -element Rank`;
				my $name = `efetch -db taxonomy -id $taxon -format xml | xtract -element ScientificName`;
				chomp($rank);
				chomp($name);

				my @rank = split(/\t/,$rank);
				my @name = split(/\t/,$name);
				my ($kingdom, $phylum, $class, $order, $family, $genus, $species) = ("","","","","","","");

				for (my $i = 0; $i < scalar(@rank); $i++){
					if ($rank[$i] eq "superkingdom"){
						$kingdom = "$name[$i]";
					}
					if ($rank[$i] eq "phylum"){
						$phylum = "$name[$i]";
					}
					if ($rank[$i] eq "class"){
						$class = "$name[$i]";
					}
					if ($rank[$i] eq "order"){
						$order = "$name[$i]";
					}
					if ($rank[$i] eq "family"){
						$family = "$name[$i]";
					}
					if ($rank[$i] eq "genus"){
						$genus = "$name[$i]";
					}
					if ($rank[$i] eq "species"){
						$species = "$name[$i]";
					}
				}
				print OUT "k__$kingdom\;p__$phylum\;c__$class\;o__$order\;f__$family\;g__$genus\;s__$species\n";
			}

		}
}

close OUT;

