#!/usr/local/bin/perl -w
use strict;
use warnings;

use Data::Dumper;
#use fund::allocation::historical;
#use fund::allocation::combination;

use fund::allocation;

my $fund = {
    1 => {
        'min' => 0,
        'max' => 100,
    },
    2 => {
        'min' => 0,
        'max' => 100,
    },
    3 => {
        'min' => 0,
        'max' => 50,
    },
    4 => {
        'min' => 0,
        'max' => 100,
    },
    5 => {
        'min' => 0,
        'max' => 100,
    },
    6 => {
        'min' => 0,
        'max' => 100,
    },
    7 => {
        'min' => 0,
        'max' => 100,
    },
    8 => {
        'min' => 0,
        'max' => 100,
    },
    9 => {
        'min' => 0,
        'max' => 100,
    },
    10 => {
        'min' => 0,
        'max' => 10,
    },
    11 => {
        'min' => 0,
        'max' => 10,
    },
    12 => {
        'min' => 0,
        'max' => 10,
    },
    13 => {
        'min' => 0,
        'max' => 10,
    },
};

my $allocation = fund::allocation->new(
    start_date  => 25560324,
    end_date    => 25570311,
    fund        => $fund,
    step        => 10,
);


$allocation->optimize();

