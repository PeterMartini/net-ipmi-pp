package Net::IPMI::PP::Packet::ASF::Pong;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(dualvar);

my @fields = (
  { format => 'N', name => 'iana' },
  { format => 'N', name => 'oem' },
  { format => 'C', name => 'entities' },
  { format => 'C', name => 'interactions' },
  { format => 'C6', name => 'reserved' },
);
sub fields { return \@fields; }

my %constants = (
  iana => {
    4542 => "Alerting Specifications Forum (ASF)",
  },
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
