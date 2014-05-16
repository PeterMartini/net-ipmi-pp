package Net::IPMI::PP::Packet::IPMI::Message;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
# Convention: confess for programming errors, croak for data errors
use Carp qw(confess croak);

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
  0x39 => "GetSessionChallenge",
  0x3a => "ActivateSession",
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
    0x39 => 'Get Session Challenge',
    0x3a => 'Activate Session',
  },
);
sub constants { return \%constants; }

sub is_valid_checksum {
  my $header = $_[0]->{header};
  my $calc = $header->{target_addr} +
             $header->{target_lun} +
             ($header->{target_netfn} << 2)
           ;
  return ($header->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
