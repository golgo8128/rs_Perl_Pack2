#!/usr/bin/env perl

use strict;
use warnings;

*::Chris_File = \ "BLA_MMS_pvalues.tab";
*::Pval_thres = \ 0.001;

local *FH;

open(FH, $::Chris_File) || die "Cannot open \"$::Chris_File\": $!";
my $header = <FH>;
my $count = 0;
while(<FH>){
    chomp;
    my @r = split(/\t/);
    for my $i (2..$#r){
	if($r[$i] <= $::Pval_thres){
	    $count += 1;
	}
    }
}
close FH;

print "$count\n";
