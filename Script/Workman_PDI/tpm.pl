#! /usr/bin/perl

require "./utilities.pm";

$usage =<<USAGE;
   usage: $0  <YPD-pvalues> <MMS-pvalues> <t-strict>

   <t-strict>   only values of {0.01, 0.001, 0.0001}
USAGE

die $usage if(@ARGV<3);

$ypd_file = shift;
$mms_file = shift;
$t_strict = shift; 

($mms, $bot, $ypd, $neither) = (-1, 0, 1, "NA");
#($mms, $bot, $ypd, $neither) = (2, 3, 1, 0);
#($mms, $bot, $ypd, $neither) = (1, 1, 0, 0);
#($mms, $bot, $ypd, $neither) = (0, 1, 1, 0);
#($mms, $bot, $ypd, $neither) = (1, 0, "NA", "NA");
#($mms, $bot, $ypd, $neither) = ("NA", 0, -1, "NA");

if ( ($t_strict eq "0.01") || ($t_strict eq "1e-2") ) {  ## if $$t_strict, $mms_thresh == 0.01
    #$t_liberal = 0.2002; $t_product = 0.002005;
    $t_liberal = 0.2;
    $t_product = 0.002;
}
elsif ( ($t_strict eq "0.001") || ($t_strict eq "1e-3") ) {
  #0.1436  0.00100324862114777     0.00014406650199682     0.00257754635745286
    $t_liberal = 0.1436;
    $t_product = 0.0001440;
}
elsif ( ($t_strict eq "0.0001") || ($t_strict eq "1e-4") ) {
  #0.111   0.000100311111480086    1.11345333742895e-05    0.000267529734317388
    $t_liberal = 0.111;
    $t_product = 1.113e-05;
}
elsif ( ($t_strict eq "0.00001") || ($t_strict eq "1e-5") ) {
#0.0901  1.00733800850381e-05    9.07611545661937e-07    2.74973056181286e-05
    $t_liberal = 0.0901;
    $t_product = 9.076e-07;
}

if(@ARGV) {
    $IDs_list = shift;
    print STDERR "using $IDs_list gene list to filter tables\n";
} else {
    $IDs_list  = "./SGD_features.list";
}

## DEFINE WHICH IDS WILL BE USED
$ID_hash = load_registry($IDs_list);

($ypd_names, $ypd_ids, $ypd_desc, $ypd_ratios, $ypd_pvals) = &read_logratios_pvalues_2($ypd_file, $ID_hash);
($mms_names, $mms_ids, $ypd_desc, $mms_ratios, $mms_pvals) = &read_logratios_pvalues_2($mms_file, $ID_hash);

$com_ids = &get_overlap_set($ypd_ids, $mms_ids);
$n = scalar(@{$com_ids});
$com_reg = {};
$com_reg = &register_ids($com_ids, $com_reg);

($ypd_names, $ypd_ids, $ypd_desc, $ypd_ratios, $ypd_pvals) = &read_logratios_pvalues_2($ypd_file, $ID_hash);
($mms_names, $mms_ids, $ypd_desc, $mms_ratios, $mms_pvals) = &read_logratios_pvalues_2($mms_file, $ID_hash);

$com_names = &get_overlap_set($ypd_names, $mms_names);
$m = scalar(@{$com_names});
#for $i (0..($n-1)){ printf "%s\t%s\n", $ypd_ids->[$i], $mms_ids->[$i]; }
#for $i (0..($m-1)){ printf "%s\t%s\n", $ypd_names->[$i], $mms_names->[$i]; }

sub new_bound_in_both {
    my($tf, $ps1, $ps2, $ids1, $ids2, $p_liberal_thr, $p_square_thr, $p_strict_thr) = @_;

    my($p1) =  $ps1->{$tf};
    my($p2) =  $ps2->{$tf};
    my($n) = scalar(@{ $p1 });
    my($i, $both, $p1_only, $p2_only);
    #$p1_only = ();
    #$p2_only = ();
    #$both = ();
    $c = 0;
    for($i=0; $i<$n; $i++) {
        if( ($p1->[$i] <= $p_strict_thr) &&
            ($p2->[$i] > $p_liberal_thr) )
        { push @{ $p1_only }, $i; }

        if( ($p2->[$i] <= $p_strict_thr) &&
            ($p1->[$i] > $p_liberal_thr) )
        { push @{ $p2_only }, $i; }

        if( ($p1->[$i] <= $p_liberal_thr) &&
            ($p2->[$i] <= $p_liberal_thr) &&
            (($p1->[$i] * $p2->[$i]) <= $p_square_thr) )
        {
            unless($ids1->[$i] eq $ids2->[$i]) {
                print STDERR "ERROR: comparing pvalues from different genes\n";
                printf STDERR "ITER:$i  \"%s\"  \"%s\"\n", $ids1->[$i], $ids2->[$i];
                exit(0);
            }
            push @{ $both }, $i;
        }
    }
    return($p1_only, $p2_only, $both);
}

$new = {};

if(0) {

  ## just to combine the 2 matrices
    foreach $tf (sort @{ $com_names }) {
	foreach $i ( 0..($n-1) ) {
	    #$new->{$tf}[$i] = $ypd_pvals->{$tf}[$i] - $mms_pvals->{$tf}[$i];
	    $new->{$tf}[$i] = $ypd_pvals->{$tf}[$i] / $mms_pvals->{$tf}[$i];
	}
    }
}
printf STDERR "TF\tC1\tC2\tC1^C2\tR1\tR2\tCALL\n";
if(1) {

    $R_thr = 0.75;

    foreach $tf (sort @{ $com_names }) {
	($mms_is, $ypd_is, $bot_is) = &new_bound_in_both($tf, $ypd_pvals, $mms_pvals, $ypd_ids, $mms_ids, 
							 $t_liberal, $t_product, $t_strict);

	$n1 = $n2 = $n3 = 0;
	if(@{ $mms_is }){ $n1 = scalar(@{ $mms_is }); }
	if(@{ $bot_is }){ $n2 = scalar(@{ $bot_is }); }
	if(@{ $ypd_is }){ $n3 = scalar(@{ $ypd_is }); }
	
	@{ $new->{$tf} } = split(":", ("$neither:" x $n));
	
	## YPD    MMS   YPD^MMS
	$R1 = $n2/($n2+$n1);
	$R2 = $n2/($n2+$n3);
	if(($R1>$R_thr) && ($R2>$R_thr)){ $call = "invarient"; }
	elsif($R1>$R_thr){ $call = "expanded"; }
	elsif($R2>$R_thr){ $call = "contracted"; }
	else { $call = "shifted"; }

	printf STDERR "$tf\t$n1\t$n3\t$n2\t%.3f\t%.3f\t$call\n", $R1, $R2;

	#foreach $i (@{ $mms_is }, @{ $bot_is }, @{ $ypd_is } )
	#{ $new->{$tf}[$i] = $ypd_pvals->{$tf}[$i] - $mms_pvals->{$tf}[$i]; }
	
	@{ $new->{$tf} }[@{ $mms_is }] = split(":", ("$mms:" x $n1));
	@{ $new->{$tf} }[@{ $bot_is }] = split(":", ("$bot:" x $n2));
	@{ $new->{$tf} }[@{ $ypd_is }] = split(":", ("$ypd:" x $n3));
    }
}


##########################
## print out the data
print "GENE\tDESCRIPT";
@com_names_ord = sort @{ $com_names };
foreach $tf ( @com_names_ord ) { print "\t$tf"; }
print "\n";

foreach $i (0..($n-1)) {
    printf "%s\t%s", $ypd_ids->[$i], $ypd_desc->[$i];
    foreach $tf ( @com_names_ord ) { 
	printf "\t%s", $new->{$tf}[$i];
	#if($new->{$tf}[$i] eq "NA") { print "\tNA"; }
	#else { printf "\t%.3e", $new->{$tf}[$i];  }
    }
    print "\n";
}
