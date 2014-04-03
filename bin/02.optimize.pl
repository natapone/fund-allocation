#!/usr/local/bin/perl -w
use strict;
use warnings;

use Data::Dumper;
use fund::allocation;

=head1
Fund
1;ทหารไทยธนรัฐ ;ต่ำ 
2;ทหารไทยธนบดี ;ต่ำ 
3;ทหารไทยธนพลัส;ต่ำ – ปานกลาง
4;ทหารไทยธนไพศาล;ต่ำ – ปานกลาง
5;ทหารไทยจัดทัพลงทุนระยะสั้น;ต่ำ – ปานกลาง
6;ทหารไทยจัดทัพลงทุนระยะกลาง;ต่ำ – ปานกลาง
7;ทหารไทยจัดทัพลงทุนระยะยาว;ต่ำ – ปานกลาง
8;ทหารไทย SET 50;ค่อนข้างสูง
9;Jumbo 25;ค่อนข้างสูง
10;ทหารไทย World Equity Index;สูง
11;ทหารไทย Emerging Markets Equity Index;สูง
12;ทหารไทย China Equity Index;สูง
13;ทหารไทย โกลด์ สิงคโปร์ ฟันด์;สูง

=cut

my $fund = {
#    1 => {
#        'min' => 0,
#        'max' => 30,
#    },
    2 => {
        'min' => 0,
        'max' => 30,
    },
#    3 => {
#        'min' => 0,
#        'max' => 30,
#    },
    4 => {
        'min' => 0,
        'max' => 30,
    },
#    5 => {
#        'min' => 0,
#        'max' => 50,
#    },
#    6 => {
#        'min' => 0,
#        'max' => 50,
#    },
#    7 => {
#        'min' => 0,
#        'max' => 50,
#    },
    8 => {
        'min' => 50,
        'max' => 100,
    },
#    9 => {
#        'min' => 0,
#        'max' => 100,
#    },
    10 => {
        'min' => 0,
        'max' => 10,
    },
#    11 => {
#        'min' => 0,
#        'max' => 10,
#    },
#    12 => {
#        'min' => 0,
#        'max' => 10,
#    },
    13 => {
        'min' => 0,
        'max' => 15,
    },
};

my $allocation = fund::allocation->new(
    start_date  => 25570101,
    end_date    => 25570911,
    fund        => $fund,
    step        => 5,
);


$allocation->optimize();

