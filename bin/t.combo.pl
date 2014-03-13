#!/usr/local/bin/perl -w
use strict;
use warnings;

use Data::Dumper;

use fund::allocation::combination;

my $combination = fund::allocation::combination->new(
    
);

my $combos = $combination->gen;
print "Combo == ", Dumper($combos), "\n";

