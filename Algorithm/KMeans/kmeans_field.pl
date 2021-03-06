#!/usr/bin/perl -w

use strict;
require Exporter;

use kmeans_func qw(determine_cluster calc_gravity_center initialize);
use Plot_field_KM;

*::CLUSTERS = \ 3;
*::RATIO = \ 0.1;

sub kmeans($){

  my $filename = shift;
  
  my @ref_position;
  my @points;
  my @points_belong;

  my @next_points_belong;
  my @target_position;

  my($POINTS, $DIM, $gene) = 
    initialize($::CLUSTERS, \@ref_position, \@points, $filename);

  for(my $iteration = 0; $iteration < 100;$iteration ++){

    system("clear");
    printf("\n>>>>> Iteration #%d <<<<<\n\n", $iteration);
    
    determine_cluster(\@next_points_belong, \@ref_position, \@points);
  
    my $fld = new Plot_field_KM -10, -10, 10, 10;
    $fld->plot_kmeans(\@points_belong, \@target_position,
		      \@ref_position, \@points, $::CLUSTERS);
    sleep 1;    

    for(my $i = 0;$i < $::CLUSTERS;$i ++){
      for(my $j = 0;$j < $POINTS;$j ++){
        $points_belong[$i]->[$j] = $next_points_belong[$i]->[$j];
      }
    }

#    print "***** Points Belongings *****\n\n";
#    for(my $i = 0;$i < $::CLUSTERS;$i ++){
#      print "Cluster #$i: ";
#      for(my $j = 0;$j < $POINTS;$j ++){
#        printf("%d ", $points_belong[$i]->[$j]);
#      }
#      print "\n";
#    }
#    print "\n";
    
    calc_gravity_center(\@points_belong, \@target_position,
                        \@ref_position, \@points);

#    print "***** Gravity Center Position *****\n\n";
#    for(my $i = 0;$i < $::CLUSTERS;$i ++){
#      printf("Cluster #%d ", $i);
#      for(my $k = 0;$k < $DIM;$k ++){
#        if(defined($target_position[$i]->[$k])){
#          printf("%+.3lf ", $target_position[$i]->[$k]);
#        }
#        else {
#          printf("------ ");
#        }
#      }
#      print "\n";
#    }
#    print "\n";

    
    for(my $i = 0;$i < $::CLUSTERS;$i ++){
      for(my $k = 0;$k < $DIM;$k ++){
        if(defined($target_position[$i]->[$k])){
          $ref_position[$i]->[$k]
            += ($target_position[$i]->[$k]
                - $ref_position[$i]->[$k]) * $::RATIO;

        }
      }
    }

 #   print "***** Reference Point Position *****\n\n";
 #   for(my $i = 0;$i < $::CLUSTERS;$i ++){
 #     printf("Cluster #%d ", $i);
 #     for(my $k = 0;$k < $DIM;$k ++){
 #       printf("%+.3lf ", $ref_position[$i]->[$k]);
 #     }
 #     print "\n";
 #   }
 #   print "\n";
  }

}

&kmeans($ARGV[0]);


