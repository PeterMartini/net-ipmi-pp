package Net::IPMI::PP::Packet::IPMI::AuthSession;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(dualvar);

my @fields = (
  { format => 'C', name => 'auth_type' },
  { format => 'N', name => 'session_seq' },
  { format => 'N', name => 'session_id' },
  { format => 'a16', name => 'auth_code' },
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
