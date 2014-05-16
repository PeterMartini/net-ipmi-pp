package Net::IPMI::PP::Packet::ASF;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

my @fields = (
  { format => 'N', name => 'iana' },
  { format => 'C', name => 'type' },
  { format => 'C', name => 'tag' },
  { format => 'C', name => 'reserved' },
  { format => 'C', name => 'len' },
);
sub fields { return \@fields; }

my %constants = (
  iana => {
    4542 => "Alerting Specifications Forum (ASF)",
  },
  type => {
    0x40 => "PONG",
    0x80 => "PING",
  }
);
sub constants { return \%constants; }

1;
