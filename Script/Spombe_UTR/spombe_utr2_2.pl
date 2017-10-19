#!/usr/local/g-language/bin/perl
# Or alternatively /usr/bin/env perl

use strict;
use warnings;

use G; # Use v.1.8.13 or higher

*::FASTA_Pombe = \ "/Users/rsaito/UNIX/Analyses/Spombe/UTR/pombe_09052011.fasta";
*::GFF_Pombe   = \ "/Users/rsaito/UNIX/Analyses/Spombe/UTR/pombe_09052011.gff";

my $gb = new G($::FASTA_Pombe, "no cache", "no msg");

my $data = {};

for my $line (readFile($::GFF_Pombe, 1)){
	
    chomp $line;
    my($chrom, $dbname, $region_type,
       $start, $end, $perd1, $strand) = split(/\t/, $line);

    my $gene = '';
    if($line =~ /mRNA (.*?)\s/){
        $gene = $1;
    }

    if($region_type eq 'CDS_parts'){
        $data->{$gene}->{start}      = $start;
        $data->{$gene}->{end}        = $end;
        $data->{$gene}->{direction}  = $strand eq '+' ? 'direct' : 'complement';
        $data->{$gene}->{chromosome} = $chrom;
        $data->{$gene}->{type}       = 'CDS';
        $data->{$gene}->{on}         = 1;
    }elsif($region_type =~ /UTR/){
        $data->{$gene}->{$region_type} = $start . '..' . $end;
    }
}

do{
    my $feature = 0;

    for my $key (sort keys %$data){
        if($data->{$key}->{chromosome} eq $gb->id()){
            $gb->{"FEATURE$feature"} = $data->{$key};
            $gb->{"FEATURE$feature"}->{feature} = $feature;
            $feature ++;
        }
    }

    say scalar($gb->cds());
    for my $cds ($gb->cds()){
        unless(length($gb->{$cds}->{"3\'-UTR"})){
            $gb->{$cds}->{on} = 0;
        }
    }
    say scalar($gb->cds());
    base_information_content($gb, -position=>'start', -filename=>$gb->id() . '.png');

}while($gb->next_locus("no msg"));
