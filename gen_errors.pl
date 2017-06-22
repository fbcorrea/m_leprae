#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

my $error = 0.01;

my $times = $ARGV[1] or die "USAGE: perl gen_errors.pl genome.fas TIMES(replicate X times)\n";

for (my $j = 0; $j < $times; $j++) {

	my $seqio_obj = Bio::SeqIO->new(-file => $ARGV[0], -format => "fasta" );

	my @nucl = ("A", "C", "G", "T");

	while (my $seq_obj = $seqio_obj->next_seq ) {
	
		my $seq = $seq_obj->seq;
		my $id = $seq_obj->display_id;
	
		my $freq = 0;
		for (my $i = 0; $i <= $seq_obj->length; $i++){
			if (rand() <= $error){
				$freq = $freq + 1;
			}
		}
#		print "$freq\n";

		for (my $i = 1; $i <= $freq; $i++) {
			my $mutloc = int(rand($seq_obj->length));
			my $ref = substr($seq,$mutloc,1);
			my $mut = $ref;
			while ($mut eq $ref) {
				$mut = $nucl[rand @nucl];
			}
			substr($seq,$mutloc,1) = $mut;
		}
        
	print ">$id\n$seq\n";
	}

}
