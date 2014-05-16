package Net::IPMI::PP::Packet::IPMI::Session;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

my @fields = (
  { format => 'C', name => 'auth_type' },
  { format => 'N', name => 'session_seq' },
  { format => 'N', name => 'session_id' },
  { format => 'C', name => 'len' },
);
sub fields { return \@fields; }

my %constants = (
  auth_type => {
    0 => "None",
    1 => "MD2",
    2 => "MD5",
    4 => "Unencrypted",
    5 => "OEM",
  },
);
sub constants { return \%constants; }

1;
