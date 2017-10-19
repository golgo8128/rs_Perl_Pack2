#!/usr/local/g-language/bin/perl
# /usr/bin/env perl

use strict;
use warnings;

use G;

*::FASTA_Pombe = \ "/Users/rsaito/UNIX/Analyses/Spombe/UTR/pombe_09052011.fasta";
*::GFF_Pombe   = \ "/Users/rsaito/UNIX/Analyses/Spombe/UTR/pombe_09052011.gff";

my %fasta = readFile($::FASTA_Pombe);

for my $line (readFile($::GFF_Pombe, 1)){
    chomp $line;
    my($chrom, $dbname, $region_type,
       $start, $end, $perd1, $strand) = split(/\t/, $line);
    next unless($region_type =~ /\'-UTR/);

    my $gene = '';
    if($line =~ /mRNA (\S+)\s/){
        $gene = $1;
    }
    my @F = split(/\t/, $line);

    print to_fasta(substr($fasta{ $chrom },
			  $start - 1,
			  $end - $start + 1),
		   -name => "$gene $region_type");

}
