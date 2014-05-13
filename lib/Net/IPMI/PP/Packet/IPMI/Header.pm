package Net::IPMI::PP::Packet::IPMI::Header;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
# Convention: confess for programming errors, croak for data errors
use Carp qw(confess croak);
use Scalar::Util qw(dualvar);

my @fields = (
  { format => 'C', name => 'target_addr' },
  { format => 'C', name => {
    'target_lun'   => { mask => 0b00000011, shift => 0 },
    'target_netfn' => { mask => 0b11111100, shift => 2 },
    }},
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
  'target_netfn' => {
    6 => 'Application Request',
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

sub is_valid_checksum {
  my $header = shift;
  my $calc = $header->{target_addr} +
             $header->{target_lun} +
             ($header->{target_netfn} << 2)
           ;
  return ($header->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
