#!/user/bin/perl -w
use strict;
use Data::Dumper;



if (@ARGV < 2){ die "USAGE: perl compare_amplification.pl silva.headers amplicons_folder\n";}

##GLOBAL VARIABLES
my %id_to_tax;
my %raw_count;
my %pre_count;
my %amp_count;
my %final_count;
my @files;

###INPUT FILES
my $silva_path = $ARGV[0] or die "SILVA HEADER PATH";
my $pcr_amplicons_path = $ARGV[1] or die "PCR_AMPLICONS PATH";


GetFileNames();
GetTaxonomiesFromSilva();
CheckCount();
PrintFinal();


sub PrintFinal{
	foreach my $tax (keys %final_count){
		print "$tax\t$raw_count{$tax}$final_count{$tax}\n";
	}
}



sub CheckCount{
	foreach my $item (@files){
		Generate2Count($item);
		foreach my $tax (keys %raw_count){
			$final_count{$tax} .= "\t$amp_count{$tax}";
		}
	%pre_count = ();
	%amp_count = ();
	}
}

sub Generate2Count{
	open FASTA, "$pcr_amplicons_path$_[0]";
	while(<FASTA>){
		chomp;
		if (/^>/){
			my ($acc, $tax) = split(" ",$_,2);
			$pre_count{$acc} = $tax;
		}
	}
	close FASTA;
	foreach my $acc (keys %id_to_tax){
		if (exists $pre_count{$acc}){
			$amp_count{$id_to_tax{$acc}} += 1;
		}
	}
	foreach my $tax (keys %raw_count){
		unless (exists $amp_count{$tax}){
			$amp_count{$tax} = 0;
		}
	}
}

sub GetTaxonomiesFromSilva{
        open FASTA, $silva_path;
        while(<FASTA>){
                chomp;
                my ($acc, $tax) = split(" ", $_, 2);
                $raw_count{$tax} += 1;
                $id_to_tax{$acc} = $tax;
        }
        close FASTA;
}


sub GetFileNames{
	opendir(DIR, "$pcr_amplicons_path");
	foreach (sort {$a cmp $b} readdir(DIR)){
		if (/fasta$/) {
			push @files, $_;
		}
	}
}
