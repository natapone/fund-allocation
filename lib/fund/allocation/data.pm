package fund::allocation::data;

use strict;
use warnings;
use Moose;
use Data::Dumper;

has 'historical'    => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_historical');
has 'fund'      => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_fund');
has 'path'      => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_path');
has 'filename'      => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_filename');
has 'start_date'    => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_start_date');
has 'end_date'      => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_end_date');

has 'th_month'  => (is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_th_month');

sub _build_end_date{return 25570311};
sub _build_start_date{return 25540311};

sub _build_path {return "./data/";}
sub _build_filename {return "Report_Mutual-fund-view_";}
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
sub _build_th_month {
    return [
        "ม.ค.",
        "ก.พ.",
        "มี.ค.",
        "เม.ย.",
        "พ.ค.",
        "มิ.ย.",
        "ก.ค.",
        "ส.ค.",
        "ก.ย.",
        "ต.ค.",
        "พ.ย.",
        "ธ.ค.",
    ];
}
sub _build_historical {
    my $self = shift;
    
    my $hist = $self->_read;
    return $hist;
}

sub _read {
    my $self = shift;
    my $historical_data;
    
    foreach my $fid (sort{$a <=> $b} keys %{$self->fund}) {
        my $file_path = $self->path . $self->filename . $fid . '.csv';
        
        if(-f $file_path) {
            $historical_data = $self->_read_file($file_path, $historical_data, $fid);
        }
    }
    
    # date index
    my @date_index;
    foreach (sort{$a <=> $b} keys %{$historical_data}) {
        push(@date_index, $_);
    }
    
    return {
        data => $historical_data,
        date_index => \@date_index,
        date_count => scalar @date_index,
    };
}

sub _read_file {
    my $self = shift;
    my $path = shift;
    my $historical_data = shift;
    my $fid = shift;
    
    open (MYFILE, $path);
    while (<MYFILE>) {
        chomp;
        
        my @data = split(',', $_);
        my $date = eval($data[0]);
        
        $date = $self->_thai_date_to_int($date);
        
        if ($date >= $self->start_date and $date <= $self->end_date) {
            $historical_data->{$date}->{$fid} = $data[1];
        }
        
    }
    close (MYFILE); 
    
    return $historical_data;
}

sub _thai_date_to_int {
    my $self = shift;
    my $date = shift;
    
    # format date yyyy mm dd
    my @date_part = split(' ', $date);
    $date = $date_part[2] . ' ' . $date_part[1] . ' ' . $date_part[0];
    
    my $m_id = 1;
    for (@{$self->th_month}) {
        my $m_str = sprintf("%02d", $m_id);
        $date =~ s/\s+$_\s+/$m_str/;
        
        
        
        $m_id++;
    }
    return $date;
}

1;






