#!/usr/bin/perl -w
use strict;

## RUNNING QIIME WITH 97 OF SIMILARITY

my $ids = $ARGV[0] or die "Usage: perl run_qiime.pl ids.txt\nYou will need a fasta folder with the samples inside and an IDS file with sample list to run.\n";

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
	open IDS, $ids;
		while (<IDS>) {
			chomp;
	
			print "::running sample $_ in $db_name{$a}\:\:\n";
			
#			print "generating map file...\n";
			chdir "results";
			mkdir "$db_name{$a}";
			chdir "$db_name{$a}";
			mkdir "$_";
			chdir "../../";
			
#			open FILE, ">map.txt";
#			print FILE "#SampleID\tInputFileName\tDescription\n$_\t$_.fas\n";
#			close FILE;
			
			print "adding qiime lables...\n";
			system "add_qiime_labels.py -i fasta -m map.txt -c InputFileName -o seqs_final";
			
			print "picking otus...\n";
			system "pick_otus.py -i seqs_final/combined_seqs.fna -r $repset{$a} -m uclust_ref -o uclust/";
			
			print "picking representative sets...\n";
			system "pick_rep_set.py -i uclust/combined_seqs_otus.txt -f seqs_final/combined_seqs.fna -o repSet.txt -l repSet.log";

			print "assigning taxonomies...\n";
			system "assign_taxonomy.py --similarity 0.97 -i repSet.txt -r $repset{$a} -t $taxonomy{$a} -o tax/";
			#system "assign_taxonomy.py --uclust_similarity 0.97 -i repSet.txt -r $repset{$a} -t $taxonomy{$a} -o tax/"; #Depends of QIIME version
			
			print "making otu table...\n";
			system "make_otu_table.py -i uclust/combined_seqs_otus.txt -t tax/repSet_tax_assignments.txt -o table.biom";

			print "converting table file format...\n";
			system 'biom convert -i table.biom -o table.txt --header-key="taxonomy" --to-tsv';
			#system 'biom convert -i table.biom -o table.txt --header-key="taxonomy" -b'; #Depends of QIIME version

			print "moving files...\n\n";
			system "mv -f rep* table* seqs_final/ tax/ uclust/ results/$db_name{$a}/$_";
		}
	close (IDS);
}
#system "rm map.txt";
