package fund::allocation;

use strict;
use warnings;
use Moose;
use Data::Dumper;

use Finance::TA;

use fund::allocation::combination;
use fund::allocation::data;

has 'start_date'    => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_start_date');
has 'end_date'      => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_end_date');

has 'fund'          => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_fund');
has 'step'          => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_step');
has 'historical'    => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_historical');
has 'combination'   => (is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_combination');

has 'risk_free_rate' => (is => 'ro', isa => 'Num', lazy => 1, builder => '_build_risk_free_rate');
has 'bank_operate_day' => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_bank_operate_day');
has 'risk_free_return' => (is => 'ro', isa => 'Num', lazy => 1, builder => '_build_risk_free_return');

has 'start_fund'    => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_start_fund');

sub _build_end_date{return 25570311};
sub _build_start_date{return 25540311};
sub _build_step {return 50;}

sub _build_risk_free_rate {return 2 / 100;}
sub _build_bank_operate_day {return 245;}

sub _build_start_fund {return 1_000;}

sub _build_risk_free_return {
    my $self = shift;
    return ($self->risk_free_rate / $self->bank_operate_day);
}

sub _build_fund {
    return {
        1 => {
            'min' => 0,
            'max' => 100,
        },
        8 => {
            'min' => 0,
            'max' => 100,
        },
        10 => {
            'min' => 0,
            'max' => 50,
        },
    };
}
sub _build_historical {
    my $self = shift;
    
    my $data_engine = fund::allocation::data->new(
        start_date  => $self->start_date,
        end_date    => $self->end_date,
    );
    
    return $data_engine->historical;
}
sub _build_combination {
    my $self = shift;
    
    my $combo_engine = fund::allocation::combination->new(
        fund => $self->fund,
        step => $self->step,
    );
    
    return $combo_engine->gen;
}

sub optimize {
    my $self = shift;
    
#    print "combination === ", Dumper($self->combination), "\n";
#    print "historical === ", Dumper($self->historical->{'data'}), "\n";
    
    print "Benchmark level: ", $self->risk_free_rate, "% per year \n";
    
    # fund name
    my @funds;
    my $fid = 0;
    my $fid_map;
    foreach (sort{$a <=> $b} keys %{$self->fund}) {
        push(@funds, $_);
        $fid_map->{$fid} = $_;
        $fid++;
    }
    print "Fund ", join(",", @funds);
    print "\n";
    
    # loop through combinations
    my $date_index = $self->historical->{'date_index'};
    foreach my $combo (@{$self->combination}) {
        
        print "Test $combo";
        print "\n";
        
        # create port
        my $portfolio = {
            start => $self->start_fund,
        };
        
        # set allocation
        my @allocations = split(',', $combo);
        
        my $fid = 0;
        foreach my $allocation (@allocations) {
            
            $portfolio->{'fid'}->{$fid_map->{$fid}}->{'allocation'} = $allocation;
            if ($allocation > 0) {
                $portfolio->{'fid'}->{$fid_map->{$fid}}->{'fund_start'} 
                            = $self->start_fund * ($allocation / 100);
                $portfolio->{'fid'}->{$fid_map->{$fid}}->{'fund'}
                            = $portfolio->{'fid'}->{$fid_map->{$fid}}->{'fund_start'}
            }
            
            $fid++;
        }
        
        foreach my $date (@$date_index) {
            
            # start day
            
            # move to port value previous
            
            
            print "------------- ", $date , "\n";
            my $data = $self->historical->{'data'}->{$date};
            
            print Dumper($data );
            
            
            foreach my $h_fid (keys $data) {
                
#                print "    ---- ", $h_fid, ": ", $data->{$h_fid}, "\n";
                
                my $h_price = $data->{$h_fid};
                # buy if data is available + fund > 0
                if ($h_price > 0 and $portfolio->{'fid'}->{$h_fid}->{'fund'} > 0) {
                    $portfolio->{'fid'}->{$h_fid}->{'volume'} = 
                                $portfolio->{'fid'}->{$h_fid}->{'fund'} / $h_price;
                    $portfolio->{'fid'}->{$h_fid}->{'price'} = $h_price;
                    $portfolio->{'fid'}->{$h_fid}->{'fund'} = 0;
                    
                    
                }
                
                
            }
            
            
            
            
            # sumarize at the end of the day
            
            print Dumper($portfolio);
            
            exit;
        }
    
    }
    
    
    
}

1;
