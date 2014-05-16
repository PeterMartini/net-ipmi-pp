package Net::IPMI::PP::Packet::IPMI::Request::ActivateSession;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

# IPMI::Request fields are implicit; they're processed by Request itself
my @fields = (
  { format => 'C', name => 'auth_type' },
  { format => 'C', name => 'priv_level' },
  { format => 'a16', name => 'challenge' },
  { format => 'N', name => 'new_sequence' },
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
  'priv_level' => {
    0x01 => 'Callback',
    0x02 => 'User',
    0x03 => 'Operator',
    0x04 => 'Administrator',
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
	     $self->{auth_type} +
             $self->{priv_level} +
             (($self->{new_sequence} & (0xff000000)) >> 24) +
             (($self->{new_sequence} & (0x00ff0000)) >> 16) +
             (($self->{new_sequence} & (0x0000ff00)) >>  8) +
             ($self->{new_sequence} & 0xff)
           ;
  for my $byte (unpack "C16", $self->{challenge}) { $calc += $byte; }
  return ($self->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
