package Net::IPMI::PP::Packet::IPMI::Request::GetSessionChallenge;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

# IPMI::Request fields are implicit; they're processed by Request itself
my @fields = (
  { format => 'C', name => {
    'unknown_1'  => { mask => 0b11110000, shift => 4 },
    'auth_type'  => { mask => 0b00001111, shift => 0 },
    }},
  { format => 'a16', name => 'user' },
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
  'auth_type' => {
    0x00 => 'None',
    0x01 => 'MD2',
    0x02 => 'MD5',
    0x04 => 'Unencrypted',
    0x05 => 'OEM',
  },
);
sub constants { return \%constants; }

sub is_valid_checksum {
  my $self = shift;
  my $calc = $self->{source_addr} +
             $self->{sequence} +
             ($self->{source_lun} << 2) +
             $self->{command} +
             ($self->{unknown_1} << 4) +
             $self->{auth_type}
           ;
  for my $byte (unpack "C16", $self->{user}) { $calc += $byte; }
  return ($self->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
