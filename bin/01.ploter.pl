#!/usr/local/bin/perl -w
use strict;
use warnings;

use Data::Dumper;
use fund::allocation;



my @fid = (2,4,8,13);
my @allocation = (5,5,75,15);

# map to fun hash
my $fund = _map_fund(\@fid, \@allocation);
#print Dumper($fund );

my $allocation = fund::allocation->new(
    start_date  => 25570101,
    end_date    => 25570911,
    fund        => $fund,
    step        => 5,
);
#my $portfolio = $allocation->optimize();
#print Dumper($portfolio );

$allocation->plot();

sub _map_fund {
    my $fid = shift;
    my $allocation = shift;
    
    my $fund;
    my $ii=0;
    foreach (@$fid) {
        $fund->{$_}->{min} = @$allocation[$ii];
        $fund->{$_}->{max} = @$allocation[$ii];
        $ii++;
    }
    return $fund;
}


