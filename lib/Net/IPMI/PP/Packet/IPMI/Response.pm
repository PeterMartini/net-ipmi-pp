package Net::IPMI::PP::Packet::RMCP;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(dualvar);

my @fields = (
  { format => 'C', name => 'target' },
  { format => 'C', name => [
    'lun'   => { mask => 0b00000011, shift => 0 },
    'netfn' => { mask => 0b11111100, shift => 2 },
    ]},
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
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
