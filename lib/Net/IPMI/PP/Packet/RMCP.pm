package Net::IPMI::PP::Packet::RMCP;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

my @fields = (
  { format => 'C', name => 'ver' },
  { format => 'C', name => 'reserved' },
  { format => 'C', name => 'sequence' },
  { format => 'C', name => 'classid' },
);
sub fields { return \@fields; }

my %constants = (
  ver => {
    6 => "RMCP_VERSION_1",
  },
  classid => {
    6 => "ASF",
    7 => "IPMI",
    8 => "OEM",
  }
);
sub constants { return \%constants; }

1;
