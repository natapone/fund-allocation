#!/usr/local/bin/perl -w
use strict;
use warnings;

use Data::Dumper;
#use fund::allocation::historical;
#use fund::allocation::combination;

use fund::allocation;

my $allocation = fund::allocation->new(
    start_date  => 25560324,
    end_date    => 25570311,
    
);


$allocation->optimize();

