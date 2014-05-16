package Net::IPMI::PP::Packet::IPMI::Header;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
# Convention: confess for programming errors, croak for data errors
use Carp qw(confess croak);

my @fields = (
  { format => 'C', name => 'target_addr' },
  { format => 'C', name => {
    'target_lun'   => { mask => 0b00000011, shift => 0 },
    'target_netfn' => { mask => 0b11111100, shift => 2 },
    }},
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
  'target_netfn' => {
    6 => 'Application Request',
    7 => 'Application Response',
  },
);
sub constants { return \%constants; }

sub is_valid_checksum {
  my $header = shift;
  my $calc = $header->{target_addr} +
             $header->{target_lun} +
             ($header->{target_netfn} << 2)
           ;
  return ($header->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
