package Net::IPMI::PP::Packet::RMCP;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(dualvar);

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
sub constant {
  confess "constant called without arguments" if @_ == 0;
  shift if ref $_[0] eq __PACKAGE__;
  my ($field, $value) = @_;
  confess "constant called without a field" unless defined $field;
  confess "constant called without a value" unless defined $value;

  return $value if ! defined $constants{$field};
  return dualvar($value, "UNKNOWN") if ! defined $constants{$field}{$value};
  return dualvar($value, $constants{$field}{$value});
}

1;
