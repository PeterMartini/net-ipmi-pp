package Net::IPMI::PP::Packet::IPMI::Response;
use parent 'Net::IPMI::PP::Packet::IPMI::Message';

use strict;
use warnings;
# Convention: confess for programming errors, croak for data errors
use Carp qw(confess croak);
use Scalar::Util qw(dualvar);

my @fields = (
  { format => 'C', name => 'source_addr' },
  { format => 'C', name => {
    'sequence'   => { mask => 0b00000011, shift => 0 },
    'source_lun' => { mask => 0b11111100, shift => 2 },
    }},
  { format => 'C', name => 'command' },
  { format => 'C', name => 'completion_code' },
);
sub fields { return \@fields; }

my %constants = (
  'completion_code' => {
    0 => 'Command Completed Normally',
  },
);
sub constant {
  confess "constant called without arguments" if @_ == 0;
  my $self = shift;
  my ($field, $value) = @_;
  confess "constant called without a field" unless defined $field;
  confess "constant called without a value" unless defined $value;

  return $self->SUPER::constant($field, $value) if ! defined $constants{$field};
  return dualvar($value, "UNKNOWN") if ! defined $constants{$field}{$value};
  return dualvar($value, $constants{$field}{$value});
}

sub is_valid_checksum {
  my $header = $_[0]->{header};
  my $calc = $header->{target_addr} +
             $header->{target_lun} +
             ($header->{target_netfn} << 2)
           ;
  return ($header->{checksum} == (0x100 - ($calc & 0xff)));
}

1;

1;
