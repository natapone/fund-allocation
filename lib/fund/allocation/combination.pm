package fund::allocation::combination;

use strict;
use warnings;
use Moose;
use Data::Dumper;

has 'fund'      => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_fund');
has 'step'      => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_step');
has 'max_port'  => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_max_port');

sub _build_fund {
    return {
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
    };
}

sub _build_step {return 50;}
sub _build_max_port {return 100;}

sub gen {
    my $self = shift;
    
    my $allocation_steps = $self->_gen_allocation_step();
    my $a_id_count = keys %$allocation_steps;
    
#    print Dumper($allocation_steps);
    
    my $a_id = 0;
    my $valid_combo = [];
    $valid_combo = $self->_recur_next_fid($allocation_steps, $a_id, undef, $valid_combo);
    
    return $valid_combo;
}

sub _recur_next_fid {
    my $self = shift;
    my $allocation_steps = shift;
    my $a_id = shift;
    my $a_combo = shift;
    my $valid_combo = shift;
    
    my $prefix = "-" x $a_id;
    $a_combo = {} if ($a_id == 0);
    
    # steps
    my $steps = $allocation_steps->{$a_id}->{'step'};
    my $fid = $allocation_steps->{$a_id}->{'fid'};
    foreach my $step (@$steps) {
#        print $prefix . "$fid: $step \n";
        
        $a_combo->{$a_id} = $step;
        my $a_id_next = $a_id + 1;
        if(defined($allocation_steps->{$a_id_next})) {
            $self->_recur_next_fid($allocation_steps, $a_id_next, $a_combo, $valid_combo);
        } else {
            # validate with max port
            my @a_combos;
            my $sum_combo = 0;
            foreach (sort{$a <=> $b} keys %$a_combo) {
                push(@a_combos, $a_combo->{$_});
                $sum_combo += $a_combo->{$_};
            }
            
            if ($sum_combo == $self->max_port) {
                push(@$valid_combo, join(",", @a_combos));
            }
#            print "= $sum_combo ========> ", join(",", @a_combos), "\n";
        }
    }
    
    
    return $valid_combo;
}

sub _gen_allocation_step {
    my $self = shift;
    
    my $allocation_step;
    my $id = 0;
    foreach my $key (sort{$a <=> $b} keys %{$self->fund}) {
        
        my $k_min = $self->fund->{$key}->{'min'};
        my $k_max = $self->fund->{$key}->{'max'};
        
        my @s;
        for (my $i = $k_min; $i <= $k_max; $i += $self->step) {
            push(@s, $i);
        }
        
        $allocation_step->{$id}->{'fid'} = $key;
        $allocation_step->{$id}->{'step'} = \@s;
        $id++;
    }
    
    return $allocation_step;
}



1;
