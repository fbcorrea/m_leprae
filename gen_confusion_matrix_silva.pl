#!/usr/bin/perl -w
use strict;
use Data::Dumper;

### GG_4FEB2011, GG_6OCT2010, GG_29NOV2010

#INPUT FILES
my $assignment = $ARGV[0]; #Taxonomy assignment file
my $reference = $ARGV[1]; #Taxonomy reference file


my %hash_predicted; #holds the prediction table
loadPrediction();

my (%hash_actual, %hash_actual_levels); #holds the actual taxonomy table
my (@array_actual_species, @array_actual_genera, @array_actual_family);
loadActual();

my @array_samples = sort keys %hash_predicted;
my @array_accessions = sort keys %hash_actual;

my %matrix; #confusion matrix
genMatrix();

my %primers = ();
printDataset();

#print Dumper(\%matrix);


#print Dumper(\%hash_actual_levels);



#FUNCTIONS
sub loadPrediction{
	open FILE_ASS, $assignment;
	while(<FILE_ASS>){
		chomp;
		if (/^(S\d+)_/){
			my ($sample, $accession, $taxonomy) = split(/\t/,$_);
			$sample = $1;
			$hash_predicted{$sample}{$accession}{$taxonomy} += 1;
		}
	}
	close FILE_ASS;
}

sub loadActual{
	open FILE_REF, $reference;
	while (<FILE_REF>){
		chomp;
		my ($accession, $taxonomy) = split (/\t/, $_);
		$hash_actual{$accession} = $taxonomy;
	}
	close FILE_REF;

	my @array_actual_levels;
	my @array_actual_levels_split;
	while (my ($accession, $taxonomy) = (each %hash_actual)){
		@array_actual_levels = ("k__","p__","c__","o__","f__","g__","s__");
		@array_actual_levels_split = split(";", $taxonomy);
		
		for (my $i = 0; $i < scalar(@array_actual_levels_split); $i ++){
			$array_actual_levels[$i] = $array_actual_levels_split[$i];
		}

		my @temp = split(" ",$array_actual_levels[6]);
		
		if (scalar(@temp) > 1) {
			$array_actual_levels[6] = "$temp[0] $temp[1]";
		} else {
			$array_actual_levels[6] = "$temp[0]";
		}

		unless ($array_actual_levels[4] eq "f__") { $hash_actual_levels{"family"}{$array_actual_levels[4]}{$accession} =()};
		unless ($array_actual_levels[5] eq "g__") { $hash_actual_levels{"genera"}{$array_actual_levels[5]}{$accession} =()};
		unless ($array_actual_levels[6] eq "s__") { $hash_actual_levels{"species"}{$array_actual_levels[6]}{$accession} =()};
	}
	@array_actual_species = sort keys %{$hash_actual_levels{"species"}};
	@array_actual_genera = sort keys %{$hash_actual_levels{"genera"}};
	@array_actual_family = sort keys %{$hash_actual_levels{"family"}};
}

sub genMatrix{
	#my $sample = "S001";
	foreach my $sample (@array_samples){
		foreach my $species (@array_actual_species){

			foreach my $count ("TP", "FN", "FP", "TN"){
				$matrix{$sample}{"species"}{$species}{$count} += 0;
			}

		 	foreach my $accession (@array_accessions){
		 		while (my ($tax, $value) = each (%{$hash_predicted{$sample}{$accession}})){
		 			my @predicted_levels = ("k__","p__","c__","o__","f__","g__","s__");
					my @predicted_levels_split = split (/;/,$tax);
					for (my $i = 0; $i < scalar(@predicted_levels_split); $i ++){
						$predicted_levels[$i] = $predicted_levels_split[$i];
					}
					
					#$matrix{$sample}{"species"}{$species}{"TOTAL"} += $hash_predicted{$sample}{$accession}{$tax};
					
					if (exists $hash_actual_levels{"species"}{$species}{$accession}){
						if ($species eq $predicted_levels[6]){
							$matrix{$sample}{"species"}{$species}{"TP"} += $hash_predicted{$sample}{$accession}{$tax};
						}
						else {
							$matrix{$sample}{"species"}{$species}{"FN"} += $hash_predicted{$sample}{$accession}{$tax};
						}
					}
					else {
						if ($species ne $predicted_levels[6]){
							$matrix{$sample}{"species"}{$species}{"TN"} += $hash_predicted{$sample}{$accession}{$tax};
						}
						else {
							$matrix{$sample}{"species"}{$species}{"FP"} += $hash_predicted{$sample}{$accession}{$tax};
						}
					}
				}
			}
		}

		foreach my $genera (@array_actual_genera){

			foreach my $count ("TP", "FN", "FP", "TN"){
				$matrix{$sample}{"genera"}{$genera}{$count} += 0;
			}

		 	foreach my $accession (@array_accessions){
		 		while (my ($tax, $value) = each (%{$hash_predicted{$sample}{$accession}})){
		 			my @predicted_levels = ("k__","p__","c__","o__","f__","g__","s__");
					my @predicted_levels_split = split (/;/,$tax);
					for (my $i = 0; $i < scalar(@predicted_levels_split); $i ++){
						$predicted_levels[$i] = $predicted_levels_split[$i];
					}
					
					#$matrix{$sample}{"genera"}{$genera}{"TOTAL"} += $hash_predicted{$sample}{$accession}{$tax};
					
					if (exists $hash_actual_levels{"genera"}{$genera}{$accession}){
						if ($genera eq $predicted_levels[5]){
							$matrix{$sample}{"genera"}{$genera}{"TP"} += $hash_predicted{$sample}{$accession}{$tax};
						}
						else {
							$matrix{$sample}{"genera"}{$genera}{"FN"} += $hash_predicted{$sample}{$accession}{$tax};
						}
					}
					else {
						if ($genera ne $predicted_levels[5]){
							$matrix{$sample}{"genera"}{$genera}{"TN"} += $hash_predicted{$sample}{$accession}{$tax};
						}
						else {
							$matrix{$sample}{"genera"}{$genera}{"FP"} += $hash_predicted{$sample}{$accession}{$tax};
						}
					}
				}
			}
		}

		foreach my $family (@array_actual_family){

			foreach my $count ("TP", "FN", "FP", "TN"){
				$matrix{$sample}{"family"}{$family}{$count} += 0;
			}

		 	foreach my $accession (@array_accessions){
		 		while (my ($tax, $value) = each (%{$hash_predicted{$sample}{$accession}})){
		 			my @predicted_levels = ("k__","p__","c__","o__","f__","g__","s__");
					my @predicted_levels_split = split (/;/,$tax);
					for (my $i = 0; $i < scalar(@predicted_levels_split); $i ++){
						$predicted_levels[$i] = $predicted_levels_split[$i];
					}

					my @temp = split(" ",$predicted_levels[6]);
					
					if (scalar(@temp) > 1) {
						$predicted_levels[6] = "$temp[0] $temp[1]";
					} else {
						$predicted_levels[6] = "$temp[0]";
					}
					
					#$matrix{$sample}{"family"}{$family}{"TOTAL"} += $hash_predicted{$sample}{$accession}{$tax};
					
					if (exists $hash_actual_levels{"family"}{$family}{$accession}){
						if ($family eq $predicted_levels[4]){
							$matrix{$sample}{"family"}{$family}{"TP"} += $hash_predicted{$sample}{$accession}{$tax};
						}
						else {
							$matrix{$sample}{"family"}{$family}{"FN"} += $hash_predicted{$sample}{$accession}{$tax};
						}
					}
					else {
						if ($family ne $predicted_levels[4]){
							$matrix{$sample}{"family"}{$family}{"TN"} += $hash_predicted{$sample}{$accession}{$tax};
						}
						else {
							$matrix{$sample}{"family"}{$family}{"FP"} += $hash_predicted{$sample}{$accession}{$tax};
						}
					}
				}
			}
		}	
	}
}

sub printDataset{
	%primers = (
		"S001"=>"E1046F-U534R",
		"S002"=>"E1099F-E826R",
		"S003"=>"E1099F-U926R",
		"S004"=>"E1391F-E1115R",
		"S005"=>"E341F-E65R",
		"S006"=>"E349F-U529R",
		"S007"=>"E349F-U534R",
		"S008"=>"E786F-E1238R",
		"S009"=>"E805F-E1064R",
		"S010"=>"E805F-E1114R",
		"S011"=>"E805F-E1115R",
		"S012"=>"E8Fa-E355R",
		"S013"=>"E8Fa-U529R",
		"S014"=>"E8Fa-U534R",
		"S015"=>"E8Fb-E357R",
		"S016"=>"E8Fb-E533Ra",
		"S017"=>"E8Fb-U534R",
		"S018"=>"E917F-E1064R",
		"S019"=>"E917F-E1238R",
		"S020"=>"E917F-E1406R",
		"S021"=>"E917F-E1407R",
		"S022"=>"E967F-E1064R",
		"S023"=>"E967F-E1065R",
		"S024"=>"E967F-E1115R",
		"S025"=>"E967F-E1406R",
		"S026"=>"E967F-E1407R",
		"S027"=>"E967F-U1406R",
		"S028"=>"E969F-E1064R",
		"S029"=>"E969F-E1114R",
		"S030"=>"E969F-E1238R",
		"S031"=>"E969F-E1406R",
		"S032"=>"E9F-E357R",
		"S033"=>"E9F-E533Ra",
		"S034"=>"E9F-U529R",
		"S035"=>"E9F-U534R",
		"S036"=>"U515F-E1065R",
		"S037"=>"U519F-E1064R"
	);

	print "SAMPLE\tPRIMERS\tLEVEL\tTAXONOMY\tTP\tFN\tFP\tTN\n";
	foreach my $sample (@array_samples){
		foreach my $species (@array_actual_species){
			my $temp = ();
			foreach my $count ("TP", "FN", "FP", "TN"){
				$temp .= "\t$matrix{$sample}{species}{$species}{$count}";
			}
			print "$sample\t$primers{$sample}\tspecies\t$species$temp\n";
		}
		foreach my $genera (@array_actual_genera){
			my $temp = ();
			foreach my $count ("TP", "FN", "FP", "TN"){
				$temp .= "\t$matrix{$sample}{genera}{$genera}{$count}";
			}
			print "$sample\t$primers{$sample}\tgenera\t$genera$temp\n";
		}
		# foreach my $family (@array_actual_family){
		# 	my $temp = ();
		# 	foreach my $count ("TP", "FN", "FP", "TN"){
		# 		$temp .= "\t$matrix{$sample}{family}{$family}{$count}";
		# 	}
		# 	print "$sample\t$primers{$sample}\tfamily\t$family$temp\n";
		# }
	}
}
