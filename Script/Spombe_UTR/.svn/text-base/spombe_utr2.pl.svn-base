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
    my @F = split(/\t/, $line);

    if($F[2] eq 'CDS_parts'){
        $data->{$gene}->{start}      = $F[3];
        $data->{$gene}->{end}        = $F[4];
        $data->{$gene}->{direction}  = $F[6] eq '+' ? 'direct' : 'complement';
        $data->{$gene}->{chromosome} = $F[0];
        $data->{$gene}->{type}       = 'CDS';
        $data->{$gene}->{on}         = 1;
    }elsif($F[2] =~ /UTR/){
        $data->{$gene}->{$F[2]} = $F[3]  . '..' . $F[4];
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
