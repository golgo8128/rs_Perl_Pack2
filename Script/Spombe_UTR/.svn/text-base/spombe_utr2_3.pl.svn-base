#!/usr/local/g-language/bin/perl
# Or alternatively /usr/bin/env perl

use strict;
use warnings;

use G; # Use v.1.8.13 or higher

*::FASTA_Pombe = \ "/Users/rsaito/UNIX/Analyses/Spombe/UTR/pombe_09052011.fasta";
*::GFF_Pombe   = \ "/Users/rsaito/UNIX/Analyses/Spombe/UTR/pombe_09052011.gff";

my $gb = new G($::FASTA_Pombe, "no cache", "no msg");

my $feature_data = {};

for my $line (readFile($::GFF_Pombe, 1)){
	
    chomp $line;
    my($chrom, $dbname, $region_type,
       $start, $end, $perd1, $strand) = split(/\t/, $line);

    my $gene = '';
    if($line =~ /mRNA (.*?)\s/){
        $gene = $1;
    }

    if($region_type eq 'CDS_parts'){
        $feature_data->{$gene}->{start}      = $start;
        $feature_data->{$gene}->{end}        = $end;
        $feature_data->{$gene}->{direction}  = $strand eq '+' ? 'direct' : 'complement';
        $feature_data->{$gene}->{chromosome} = $chrom;
        $feature_data->{$gene}->{type}       = 'CDS';
        $feature_data->{$gene}->{on}         = 1;
    }elsif($region_type =~ /UTR/){
        $feature_data->{$gene}->{$region_type} = $start . '..' . $end;
    }
}

do{
    my $feature = 0;

    for my $gene (sort keys %$feature_data){
        if($feature_data->{$gene}->{chromosome} eq $gb->id()){
            $gb->{"FEATURE$feature"} = $feature_data->{$gene};
            $gb->{"FEATURE$feature"}->{feature} = $feature;
            $feature ++;
        }
    }

    say scalar($gb->cds());
    for my $cds_feat ($gb->cds()){
   		print join(",", keys(%{$gb->{$cds_feat}})), "\n";
        unless(length($gb->{$cds_feat}->{"3\'-UTR"})){
            $gb->{$cds_feat}->{on} = 0;
            print "$cds_feat OFF!\n";
        }
    }
    say scalar($gb->cds());
    base_information_content($gb, -position=>'start', -filename=>$gb->id() . '.png');

}while($gb->next_locus("no msg"));
