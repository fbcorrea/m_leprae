#!/usr/bin/perl -w
use strict;

## RUNNING QIIME WITH 97 OF SIMILARITY
my $threads = $ARGV[0] or die "Usage: perl run_qiime.pl THREADS \nYou will need a fasta folder with the samples inside.\n";
#my $threads = $ARGV[0] // 10;

my @databases = ("gg01","gg02","gg03","slv01","slv02","slv03");

my %db_name = (
	"gg01" => "gg_06oct2010",
	"gg02" => "gg_29nov2010",
	"gg03" => "gg_04feb2011",
	"slv01" => "silva_111",
	"slv02" => "silva_118",
	"slv03" => "silva_123",
);

my %repset = (
	"gg01" => "/storage/Data/db/leprae/data/databases/otus/greengenes/gg_otus_6oct2010/rep_set/gg_97_otus_6oct2010.fasta",
	"gg02" => "/storage/Data/db/leprae/data/databases/otus/greengenes/gg_otus_29nov2010/rep_set/gg_97_otus_29nov2010.fasta",
	"gg03" => "/storage/Data/db/leprae/data/databases/otus/greengenes/gg_otus_4feb2011/rep_set/gg_97_otus_4feb2011.fasta",
	"slv01" => "/storage/Data/db/leprae/data/databases/otus/silva/silva_111/rep_set/97_Silva_111_rep_set.fasta",
	"slv02" => "/storage/Data/db/leprae/data/databases/otus/silva/silva_118/rep_set/97/Silva_119_rep_set97.fna",
	"slv03" => "/storage/Data/db/leprae/data/databases/otus/silva/silva_123/rep_set/rep_set_16S_only/97/97_otus_16S.fasta",
);

my %taxonomy = (
	"gg01" => "/storage/Data/db/leprae/data/databases/otus/greengenes/gg_otus_6oct2010/taxonomies/otu_id_to_greengenes.txt",
	"gg02" => "/storage/Data/db/leprae/data/databases/otus/greengenes/gg_otus_29nov2010/taxonomies/otu_id_to_greengenes.txt",
	"gg03" => "/storage/Data/db/leprae/data/databases/otus/greengenes/gg_otus_4feb2011/taxonomies/greengenes_tax.txt",
	"slv01" => "/storage/Data/db/leprae/data/databases/otus/silva/silva_111/taxonomy/97_Silva_111_taxa_map.txt",
	"slv02" => "/storage/Data/db/leprae/data/databases/otus/silva/silva_118/taxonomy/97/taxonomy_97_7_levels.txt",
	"slv03" => "/storage/Data/db/leprae/data/databases/otus/silva/silva_123/taxonomy/16S_only/97/taxonomy_7_levels.txt",
);

mkdir "results";

foreach $a (@databases){
	mkdir "results/$db_name{$a}";
	print "::running samples in $db_name{$a}\:\:\n";
	print "adding qiime lables...\n";
	system "add_qiime_labels.py -i fasta -m map.txt -c InputFileName -o seqs_final";

	print "assigning taxonomies...\n";
	system "parallel_assign_taxonomy_uclust.py --similarity 0.97 -i seqs_final/combined_seqs.fna -r $repset{$a} -t $taxonomy{$a} -o tax/ -O $threads";

#	print "generating uc file...\n";
#	system "vsearch --derep_fulllength seqs_final/combined_seqs.fna -uc derep.uc";
#
#	print "generating biom file...\n";
#	system "biom from-uc -i derep.uc -o table.biom";
#	system "biom add-metadata -i table.biom -o table_tax.biom --observation-metadata-fp tax/combined_seqs_tax_assignments.txt --observation-header OTUID,taxonomy --sc-separated taxonomy";
#	system "biom convert -i table_tax.biom -o table_tax.txt --to-tsv --header-key taxonomy";
#
	print "moving files...\n\n";
#	system "mv -f table* seqs_final/ tax/ derep.uc results/$db_name{$a}";
	system "mv -f seqs_final/ tax/ results/$db_name{$a}";
}
