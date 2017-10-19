############################################
sub sum {
    my(@l) = @_;
    my($i, $s);
    foreach $i (@l) { $s+=$i; }
    return($s);
}
############################################
sub max {
    my(@l) = @_;
    my($i, $m);
    $m = $l[0];
    foreach $i (@l) {
	if($i>$m) { $m=$i; }
    }
    return($m);
}
############################################
sub min {
    my(@l) = @_;
    my($i, $m);
    $m = $l[0];
    foreach $i (@l) {
	if($i<$m) { $m=$i; }
    }
    return($m);
}

#############################################
##
sub order_of_index {  ## decreasing
  my($ref) = shift;
  my($i);
  #my(@iar, @iar_sorted, @ret);
  my(@iar, @iar_sorted, $ret);
  $ret = ();
  #printf "%d\n", $#$ref;
  for $i (0..$#$ref) { @{$iar[$i]} = ($ref->[$i], $i); }
  @iar_sorted = sort { $a->[0] <=> $b->[0] } @iar;
  #for $i (0..$#$ref) { $ret[$i] = $iar_sorted[$i][1]; }
  #return \@ret;
  for $i (0..$#$ref) { $ret->[$i] = $iar_sorted[$i][1]; }
  return $ret;
}
#############################################
##
sub order_of_index2 {
  my($ref, $inc_dec) = @_;
  my($i);

  my(@iar, @iar_sorted, $ret);
  $ret = ();

  for $i (0..$#$ref) { @{$iar[$i]} = ($ref->[$i], $i); }

  if($inc_dec =~ /^inc/){
      #print STDERR "ORDERED INCREASING\n";
      @iar_sorted = sort { $a->[0] <=> $b->[0] } @iar; 
  }
  else {       
      #print STDERR "ORDERED DECREASING\n";
      @iar_sorted = sort { $b->[0] <=> $a->[0] } @iar;
  }

  for $i (0..$#$ref)
  { $ret->[$i] = $iar_sorted[$i][1]; }

  return $ret;
}
#############################################
##
sub order_of_index3 {
  my($ref, $inc_dec, @na_strings) = @_;
  my($i);
  my(%na_str);

  my(@iar, @iar_sorted, $ret);
  $ret = ();

  foreach $i (@na_strings) {
      $na_str{$i}++;
  }
  my($minv, $maxv, $v, $minmax);
  for $i (0..$#$ref) {
      $v = $ref->[$i];
      unless(exists $na_str{$v} ) {
	  if($i==0){ $minv = $maxv = $v; }
	  else {
	      if($v < $minv){ $minv = $v; }
	      if($v > $maxv){ $maxv = $v; }
	  }
      }     
  }
  if( $inc_dec =~ /^inc/ ){ $minmax = $maxv + 1; }
  else{ $minmax = $minv - 1; }

  for $i (0..$#$ref) { 
      $v = $ref->[$i];
      if( exists $na_str{$v} ) { $v = $minmax; }
      @{$iar[$i]} = ($v, $i);
  }

  if($inc_dec =~ /^inc/){
      #print STDERR "ORDERED INCREASING\n";
      @iar_sorted = sort { $a->[0] <=> $b->[0] } @iar; 
  }
  else {       
      #print STDERR "ORDERED DECREASING\n";
      @iar_sorted = sort { $b->[0] <=> $a->[0] } @iar;
  }

  for $i (0..$#$ref)
  { $ret->[$i] = $iar_sorted[$i][1]; }

  return $ret;
}
#############################################
## takes 2 ref-to-a-lists and finds the 
## intersection of their entries
##
## returns: ref-to-a-list

sub get_overlap_set {
    my($rL1, $rL2) = @_;
    my($t, %h1, %h2);
    #my(@c);
    my($c) = ();

    #printf STDERR "get_overlap_set:: %d %d\n", scalar(@{$rL1}), scalar(@{$rL2});
    foreach $t (@{ $rL1 }) { $h1{$t}++; }
    #printf STDERR "\"%s\"\n",  join("\"\n\"", @{ $rL2 });
    foreach $t (@{ $rL2 }) { 
	if(exists $h1{$t}){
	    unless(exists $h2{$t}) { 
		#push @c, $t;
		push @{ $c }, $t;
		$h2{$t}++;
	    }
	}
    }
    #printf STDERR "get_overlap_set:: %d\n", scalar(@c);
    #return(\@c);
    return($c);
}

#############################################
## takes 2 ref-to-a-lists and finds the 
## intersection size of their entries
##
## returns: integer

sub overlap_size {
    my($ref1, $ref2) = @_;
    my ($ol) = get_overlap_set($ref1, $ref2);
    return( scalar(@{ $ol }) );
}

#############################################
## takes 2 ref-to-a-lists and finds the union 
## of their entries
##
## returns: ref-to-a-list

sub get_union_set {
    my ($rL1, $rL2) = @_;
    my ($t, %h, @c);
    foreach $t (@{ $rL1 }) { $h{$t}++; }
    foreach $t (@{ $rL2 }) { $h{$t}++; }
    @c = sort keys %h;
    return(\@c);
}
#############################################
## get IDs whos pvalues are leq to a threshold
##
sub get_ids_passed {
    my($ps, $ids, $ord, $thr) = @_;
    my(@passed, $i, @c);

    #printf "%d\t%d\t%d\t%.2f\n", scalar(@{$ps}), scalar(@{$ids}), scalar(@{$ord}), $thr;
    my($max_ind) = scalar(@{$ps}) - 1;
    for($i=0; $ps->[$ord->[$i]] <= $thr; $i++){
	$id = $ids->[$ord->[$i]];
	if($id eq "") { printf STDERR "coudn't find ID for index $i %d\n", $ord->[$i];  exit(); }
	push @c, $id;
	last if ($i==$max_ind);
    }
    
    return(\@c);
}
#############################################
## get IDs whos pvalues are leq to a threshold
sub get_ids_passed2 {
    my($vals, $ids, $thr, $comp) = @_;
    my(@passed, $i, $j, $inc_dec);

    my($ord, $ret);
    my($max_i) = scalar(@{$vals});
    
    if($comp =~ /^gt/) { $inc_dec = "dec"; }
    else { $inc_dec = "inc"; }

    ##$ord = &order_of_index2($vals, $inc_dec);
    $ord = &order_of_index3($vals, $inc_dec, "NA");

    $i = 0;
    if($comp =~ /^lte/) {
	while( ($vals->[$ord->[$i]] <= $thr) && ($i<$max_i) ) { $i++; };
    }
    elsif($comp =~ /^lt/) {
	while( ($vals->[$ord->[$i]] < $thr) && ($i<$max_i) ) { $i++; };
    }
    elsif($comp =~ /^gte/) {
	while( ($vals->[$ord->[$i]] >= $thr) && ($i<$max_i) ) { $i++; };
    }
    elsif($comp =~ /^gt/) {
	while( ($vals->[$ord->[$i]] > $thr) && ($i<$max_i) ) { $i++; };
    }

    $ret = ();
    for $j (0..($i-1))
    { $ret->[$j] = $ids->[ $ord->[$j] ]; }

    return( $ret );
}

#############################################
## takes a ref-to-a-list and ref-to-a-hash
## creates hash entries for items in the list
##
## returns: the modified ref-to-a-hash

sub register_ids {
    my($lst, $reg) = @_;
    my($i, $n);
    $n = scalar(@{ $lst });
    for($i; $i<$n; $i++) {
	$reg->{$lst->[$i]}++;
    }
    return($reg);
}

#############################################
sub unique {
    my($lst) = shift;
    my($reg) = {};
    my($ret) = ();
    $reg = register_ids($lst, $reg);
    @{ $ret } = keys %{ $reg };
    return($ret);
}

#############################################
sub load_registry {
    my($file) = shift;
    my($reg);
    my($lst) = read_list($file);
    $reg = register_ids($lst, $reg);
    return($reg);
}

#############################################
sub process_name {
    my($raw) = shift;
    my($name) = $raw;
    my(@l);
    if($raw =~ /[.]X/) {
	@l = split(/[.]/, $raw);
	$name = $l[0];
    }
    return($name);
    #return("\U$name");
}

#############################################
##
sub read_list {
    my($file) = shift;
    my(%h, @l);

    open(FILE, $file) or die "can't open $file: $!\n";
    while(<FILE>){ 
	chomp; 
	@l=split; 
	$h{$l[0]}++; 
    }
    close(FILE);
    @l = keys %h;
    return(\@l);
}


#############################################
##
sub read_pvalues {
    my ($file, $idHash) = @_;
    my ($id, $desc, @l, $i, $p, $ids, $names, $pvals);

    open(BLA, $file);   
    while(<BLA>){
	chomp;
	@l    = split(/\t/);
	$id   = shift(@l);
	$desc = shift(@l);
	if($. == 1) {
	    for $i (0..$#l) { 
		#push @{ $names },  "\U$l[$i]";  
		push @{ $names }, process_name($l[$i]); 
	    }
	} else {
	    if(exists $idHash->{$id}) {
		push @{ $ids }, $id;
		for $i (0..$#l) {
		    $p = $l[$i];
		    ## need to do this to get decreasing sort to work
		    if($p eq "NA") { $p = 1; }
		    push @{ $pvals->{$names->[$i]} }, $p;
		}
	    }
	}
    }
    close(BLA);
    return($names, $ids, $pvals);  ## ref2list, ref2list, ref2hash
}

#############################################
##
sub read_pvalues_2 {
    my ($file, $idHash, $annCol) = @_;
    my ($id, $desc, $i, $p, $ids, $names, $pvals, $descs);
    my(@l);
    my($n_ids) = scalar(keys %{ $idHash });
    my(%found);
    my(%warned);

    if(!defined $annCol){ $annCol = 2; }

    open(BLA, $file);   
    while(<BLA>){
	chomp;
	@l    = split(/\t/);
	$id   = shift(@l);
        if($annCol > 1)
	{ $desc = shift(@l); }
        else { $desc = $id; }
	if($. == 1) {
	    for $i (0..$#l) {
		push @{ $names }, $l[$i];
		#push @{ $names },  "\U$l[$i]";  
		#push @{ $names }, process_name($l[$i]); 
	    }
	} else {
	    #if($n_ids == 0){ $found{$id}++; }
	    if( (exists $idHash->{$id}) || ($n_ids == 0) )
		## (exists $found{$id} ) ) ## only one instance of each row ID
	    {
		$found{$id}++;
		if( ($found{$id} > 1) && ($warned{$id} < 1) ) {
		    $warned{$id}++;
		    printf STDERR "WARNING: \"$id\" not unique\n";
		}
		#unless(exists $found{$id}){ $found{$id}++; }
		push @{ $ids }, $id;
		push @{ $descs }, $desc;
		for $i (0..$#l) {
		    $p = $l[$i];
		    ## need to do this to get decreasing sort to work
		    if($p eq "NA") { $p = 1; }
		    push @{ $pvals->{$names->[$i]} }, $p;
		}
	    }
	}
    }
    close(BLA);
    #printf STDERR "$file (n,m)=(%d,%d)\n", scalar(@{$ids}), scalar(@{$names});
    return($names, $ids, $descs, $pvals);  ## ref2list, ref2list, ref2list, ref2hash
}

#############################################
##
sub read_table {
    my ($file, $ann_cols, $idHash) = @_;
    my ($id, @desc, @l, $i, $p, $ids, $names, $pvals);
    my ($valid_reg) = scalar(keys %{ $idHash });
    open(TAB, $file);
    while(<TAB>){
	chomp;
	@l    = split(/\t/);
	$id   = shift(@l);
	undef @desc;
	for $i (2..$ann_cols){ push @desc, shift(@l); }

	if($. == 1) {
	    for $i (0..$#l) { 
		#push @{ $names }, process_name($l[$i]); 
		push @{ $names }, $l[$i]; 
	    }
	}
	else {
	    if( ($valid_reg == 0) || (exists $idHash->{$id}) ) {
		push @{ $ids }, $id;
		push @{ $descs }, join("\t", @desc);
		for $i (0..$#l) {
		    $p = $l[$i];
		    ## need to do this to get decreasing sort to work
		    if($p eq "NA") { $p = 1; }
		    push @{ $pvals->{$names->[$i]} }, $p;
		}
	    }
	}
    }
    close(TAB);
    return($names, $ids, $descs, $pvals);  ## ref2list, ref2list, ref2list, ref2hash
}

#############################################
##
sub filter_real_number {
    my($r, $alt) = @_;
    if( ($r eq "NA") || ($r eq "Inf") || ($r eq "-Inf") || ($r eq "NaN")) 
    { $r = $alt; }
    return($r);
}

#############################################
##
sub read_logratios_pvalues {
    my ($file, $idHash) = @_;
    my ($id, $desc, @l, $ids, $i, $p, $r, $n, $mid_n, $names, $lratios, $pvals);

    open(BLA, $file);   
    while(<BLA>){
	chomp;
	@l    = split(/\t/);
	$id   = shift(@l);
	$desc = shift(@l);
	if($. == 1) {
	    $n = scalar(@l);
	    $mid_n = $n/2;
	    #printf STDERR "MID $mid_n\n";
	    for $i (0..$#l) {
		#push @{ $names },  "\U$l[$i]"; 
		push @{ $names }, process_name($l[$i]); 
	    }
	} else {
	    $n_i = scalar(@l);
	    die "$file line:$. $n_i $n $_\n" if ($n_i != $n);
	    if(exists $idHash->{$id}) {
		push @{ $ids }, $id;
		for $i (0..($mid_n-1)) {
		    $r = $l[$i];
		    ## need to do this to get sort to work
		    #if($r eq "NA" || $r eq "Inf") { $r = 0; }
		    $r = &filter_real_number($r, 0);
		    push @{ $lratios->{$names->[$i]} }, $r;
		}
		for $i ($mid_n..$#l) {
		    $p = $l[$i];
		    ## need to do this to get decreasing sort to work
		    #if($p eq "NA" || $r eq "Inf") { $p = 1; }
		    $p = &filter_real_number($p, 1);
		    push @{ $pvals->{$names->[$i]} }, $p;
		}
	    }
	}
    }
    close(BLA);
    @{ $names } = @{ $names }[$mid_n..$#l];
    return($names, $ids, $lratios, $pvals);  ## ref2list, ref2list, ref2hash
}
#############################################
##
sub read_logratios_pvalues_2 {
    my ($file, $idHash, $annCols) = @_;
    my ($id, $desc, @l, $ids, $descs, $i, $p, $r, $n, 
	$mid_n, $names, $lratios, $pvals);

    my($n_ids) = scalar(keys %{ $idHash });

    if(!defined $annCol){ $annCol = 2; }

    open(BLA, $file);
    while(<BLA>){
	chomp;
	@l    = split(/\t/);
	$id   = shift(@l);
        if($annCol > 1)
	{ $desc = shift(@l); }
        else { $desc = $id; }
	if($. == 1) {
	    $n = scalar(@l);
	    $mid_n = $n/2;
	    #printf STDERR "MID $mid_n\n";
	    for $i (0..$#l) {
		push @{ $names }, $l[$i];
	    }
	} else {
	    $n_i = scalar(@l);
	    die "$file line:$. $n_i $n $_\n" if ($n_i != $n);

	    if( (exists $idHash->{$id}) || ($n_ids == 0) ) {
		push @{ $ids }, $id;
		push @{ $descs }, $desc;
		for $i (0..($mid_n-1)) {
		    $r = $l[$i];
		    ## need to do this to get decreasing sort to work
		    ##if($r eq "NA") { $r = 0; }
		    ##$r = &filter_real_number($r, 0);
		    $r = &filter_real_number($r, "NA");
		    push @{ $lratios->{$names->[$i]} }, $r;
		}
		for $i ($mid_n..$#l) {
		    $p = $l[$i];
		    ## need to do this to get decreasing sort to work
		    ##if($p eq "NA") { $p = 1; }
		    ##$p = &filter_real_number($p, 1);
		    $p = &filter_real_number($p, "NA");
		    push @{ $pvals->{$names->[$i]} }, $p;
		}
	    }
	}
    }
    close(BLA);
    @{ $names } = @{ $names }[$mid_n..$#l];
    return($names, $ids, $descs, $lratios, $pvals);  ## ref2list, ref2list, ref2hash
}

#sub write_logratios_pvalues {
#    my ($file, $idHash)
#
#}

return(1);
