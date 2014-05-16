package Net::IPMI::PP::Packet::IPMI::Request::GetChannelAuth;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

# IPMI::Request fields are implicit; they're processed by Request itself
my @fields = (
  { format => 'C', name => {
    'v15_compatible'   => { mask => 0b10000000, shift => 7 },
    'unknown_1'        => { mask => 0b01110000, shift => 4 },
    'channel'          => { mask => 0b00001111, shift => 0 },
    }},
  { format => 'C', name => {
    'unknown_2'        => { mask => 0b11110000, shift => 4 },
    'priv_level'       => { mask => 0b00001111, shift => 0 },
    }},
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
  'channel' => {
    0x0e => 'Current',
  },
  'priv_level' => {
    0x4 => 'Administrator',
  },
);
sub constants { return \%constants; }

sub is_valid_checksum {
  my $self = shift;
  my $calc = $self->{source_addr} +
             $self->{sequence} +
             ($self->{source_lun} << 2) +
             $self->{command} +
             ($self->{v15_compatible} << 7) +
             ($self->{unknown_1} << 4) +
             $self->{channel} +
	     ($self->{unknown_2} << 4) +
             $self->{priv_level}
           ;
  return ($self->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
