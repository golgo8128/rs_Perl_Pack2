#!/usr/local/g-language/bin/perl

use strict;
use warnings;

use G;

*::FASTA_Pombe = \ "pombe_09052011.fasta";
*::GFF_Pombe   = \ "pombe_09052011.gff";

my %fasta = G::Messenger::readFile($::FASTA_Pombe);

for my $key (keys %fasta){

    print $key, "\n";
    print substr($fasta{ $key }, 0, 100), "\n";
    
}

for my $line (readFile($::GFF_Pombe, 1)){
    chomp $line;
    my($chr, $dbname, $region_type) = split(/\t/, $line);
    next unless($region_type =~ /\'-UTR/);

    print $line, "\n";

}

