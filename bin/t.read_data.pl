#!/usr/local/bin/perl -w
use strict;
use warnings;

use Data::Dumper;
use fund::allocation::data;

my $data = fund::allocation::data->new(
    
);

my $hist = $data->historical;
print "hist == ", Dumper($hist), "\n";
