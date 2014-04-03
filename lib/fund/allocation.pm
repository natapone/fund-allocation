package fund::allocation;

use strict;
use warnings;
use Moose;
use Data::Dumper;

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

=head1 DESCRIPTION
Annual Return   = (value[end]/value[start]) – 1
daily_rets[i]   = (value[i]/value[i-1]) – 1
std_metric      = stdev(daily_rets)
Sharpe Ratio    = (average(daily_rets)/stdev(daily_rets)) * sqrt(250)
    * k = sqrt(250) for daily returns

=cut

sub _build_end_date{return 25570311};
sub _build_start_date{return 25540311};
sub _build_step {return 50;}

sub _build_risk_free_rate {return 2.5 / 100;}
sub _build_bank_operate_day {return 250;}

sub _build_start_fund {return 100;}

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
        fund        => $self->fund,
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

sub plot {
    my $self = shift;
    
    my $portfolios = $self->optimize();
#    print Dumper($portfolio );
    
    
    foreach my $combo (keys %$portfolios) {
        print "------ Plot $combo ------\n";
        my $rate_of_return = $portfolios->{$combo}->{'rate_of_return'};
        my $current_balance = $portfolios->{$combo}->{'start'};
        print $current_balance, "\n";
        foreach my $ror (@$rate_of_return) {
#            print "-------------- $ror \n";
            $current_balance *= ($ror + 1);
            print $current_balance, "\n";
        }
        
    }
    
}

sub optimize {
    my $self = shift;
    
#    print "combination === ", Dumper($self->combination), "\n";
#    print "historical === ", Dumper($self->historical->{'data'}), "\n";
#    exit;
    print "Benchmark level: ", $self->risk_free_rate * 100, "% per year \n";
    print "Test period: ", $self->start_date, " - ", $self->end_date, "\n";
    
    # fund name
    my @funds;
    my $fid = 0;
    my $fid_map;
    foreach (sort{$a <=> $b} keys %{$self->fund}) {
        push(@funds, $_);
        $fid_map->{$fid} = $_;
        $fid++;
    }
    print "Fund,", join(",", @funds);
    print ",sharpe_ratio,annual_return";
    print ",sharpe_ratio_sort,annual_return_sort";
    print "\n";
    
    # loop through combinations
    my $portfolio_allocation;
    my $date_index = $self->historical->{'date_index'};
    foreach my $combo (@{$self->combination}) {
        
        print "allocation,$combo";
        
        # create port
        my $portfolio = {
            start => $self->start_fund,
        };
        my @rate_of_return;
        
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
        
        my $iii=1;
        foreach my $date (@$date_index) {
            
            ### start day ###
            
            # move to port balance to previous balance
            if (defined($portfolio->{'balance'})) {
                $portfolio->{'balance_previous'} = $portfolio->{'balance'};
            } else {
                $portfolio->{'balance_previous'} = $self->start_fund;
            }
            
            
            my $data = $self->historical->{'data'}->{$date};
#            print "------------- ", $date , "------------- ","\n";
#            print Dumper($data );
            
            # transaction
            foreach my $h_fid (keys $data) {
                
#                print "    ++++ ", $h_fid, ": ", $data->{$h_fid}, "\n";
                
                my $h_price = $data->{$h_fid};
                # buy if data is available + fund > 0
                if ($h_price > 0 and 
                    defined($portfolio->{'fid'}->{$h_fid}->{'fund'}) and
                    $portfolio->{'fid'}->{$h_fid}->{'fund'} > 0
                ) {
                    $portfolio->{'fid'}->{$h_fid}->{'volume'} = 
                                $portfolio->{'fid'}->{$h_fid}->{'fund'} / $h_price;
                    $portfolio->{'fid'}->{$h_fid}->{'price'} = $h_price;
                    $portfolio->{'fid'}->{$h_fid}->{'fund'} = 0;
                    
                } elsif (defined($portfolio->{'fid'}->{$h_fid}->{'volume'}) and
                    $portfolio->{'fid'}->{$h_fid}->{'volume'} > 0
                ) {
                    # update port value
                    $portfolio->{'fid'}->{$h_fid}->{'price'} = $h_price;
                }
                
            }
            
            # sumarize at the end of the day
            my $port_balance = 0;
            foreach my $p_fid (keys %{$portfolio->{'fid'}}) {
                my $p_data = $portfolio->{'fid'}->{$p_fid};
#                print "    ---- ", $p_fid, ": ", $portfolio->{'fid'}->{$p_fid}, "\n";
                
                next if ($p_data->{'allocation'} == 0);
                $port_balance += $p_data->{'fund'};
                if (defined($p_data->{'volume'}) and $p_data->{'volume'} > 0) {
                    $port_balance += ($p_data->{'volume'} * $p_data->{'price'})
                }
                
            }
            $portfolio->{'balance'} = $port_balance;
            
            # daily rate of return
            my $ror = ($portfolio->{'balance'} / $portfolio->{'balance_previous'}) - 1;
#            print "ror +++++ $ror - ", $self->risk_free_return ," \n";
            $ror -= $self->risk_free_return;
            push(@rate_of_return, $ror);
            
#            print Dumper($portfolio);
#            print Dumper(\@rate_of_return);
#            exit if ($iii >= 3);
#            $iii++;
        }
        
        # end of combo calculation
        $portfolio->{'rate_of_return'} = \@rate_of_return;
        
        #==Evaluation==
        $portfolio = $self->_evaluate($portfolio);
        print ",", $portfolio->{'evaluation'}->{'sharpe_ratio'} ;
        print ",", $portfolio->{'evaluation'}->{'annual_return'};
        print ",", int($portfolio->{'evaluation'}->{'sharpe_ratio'} + 0.5) ; # round
        print ",", int($portfolio->{'evaluation'}->{'annual_return'} + 0.5); # round
        print "\n";
        
        $portfolio_allocation->{$combo} = $portfolio;
#        print Dumper($portfolio->{'evaluation'});
#        exit;
    }
    
    return $portfolio_allocation;
}

sub _evaluate {
    my $self = shift;
    my $portfolio = shift;
        
        my $rate_of_return = $portfolio->{'rate_of_return'};
#        print Dumper($rate_of_return);
        
        my $ror_count = scalar @$rate_of_return;
#        print "count ==== $ror_count \n";
        
        # Sum rate of return
        my $ror_sum = $self->math_sum($rate_of_return);
#        print "+++++++ SUM == $ror_sum \n";
        
        # Average
        my $ror_avg = $ror_sum / $ror_count;
#        print "+++++++ AVG == $ror_avg \n";
        
        # Std dev
        my $ror_stddev = $self->math_stddev($rate_of_return, $ror_avg, $ror_count);
#        print "+++++++ STDDEV == $ror_stddev \n";
        
        # Sharpe Ratio
        $portfolio->{'evaluation'}->{'sharpe_ratio'} = 
            sprintf("%.5f", 
            ($ror_avg / $ror_stddev) * sqrt($self->bank_operate_day));
        
        # Annual Return
        $portfolio->{'evaluation'}->{'annual_return'} = 
            sprintf("%.5f", 
            $ror_avg * $self->bank_operate_day * 100);
        
    return $portfolio;
}

sub math_sum {
    my $self = shift;
    my $data = shift;
    
    my $sum = 0;
    for (@$data) {
        $sum += $_;
    }
    
    return $sum;
}

sub math_stddev {
    my $self = shift;
    my $data = shift;
    my $avg = shift;
    my $count = shift;
    
    my $stddev = 0;
    for (@$data) {
        $stddev += ($_ - $avg)**2;
    }
    
    $stddev /= $count;
    $stddev = sqrt($stddev);
    
    return $stddev;
}

1;
