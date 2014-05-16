package Net::IPMI::PP::Packet::ASF::Pong;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

my @fields = (
  { format => 'N', name => 'iana' },
  { format => 'N', name => 'oem' },
  { format => 'C', name => 'entities' },
  { format => 'C', name => 'interactions' },
  { format => 'a6', name => 'reserved' },
);
sub fields { return \@fields; }

my %constants = (
  iana => {
    4542 => "Alerting Specifications Forum (ASF)",
  },
);
sub constants { return \%constants; }

1;
