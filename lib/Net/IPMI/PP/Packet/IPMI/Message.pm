package Net::IPMI::PP::Packet::IPMI::Message;
use parent 'Net::IPMI::PP::Packet';

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
);
sub fields { return \@fields; }

my %requestclasses = (
  0x38 => "GetChannelAuth",
);

sub unpack {
  my ($class, $data) = @_;
  (my $self, $data) = Net::IPMI::PP::Packet::unpack(bless({}, $class), $data);
  my $commandpkg = $requestclasses{0+$self->{command}};
  croak "No support for command type: $self->{command} (" . ($self->{command}+0) .")"
    unless defined $commandpkg;
  my $package = "${class}::${commandpkg}";
  eval "require $package" or confess "Could not find package: $package";
  bless $self, $package;
  return $self->unpack($data);
}

my %constants = (
  'command' => {
    0x38 => 'Get Channel Authentication Capabilities',
  },
);
sub constant {
  confess "constant called without arguments" if @_ == 0;
  my $self = shift;
  my ($field, $value) = @_;
  confess "constant called without a field" unless defined $field;
  confess "constant called without a value" unless defined $value;

  return $value if ! defined $constants{$field};
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
