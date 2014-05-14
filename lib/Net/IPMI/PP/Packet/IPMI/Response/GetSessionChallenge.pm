package Net::IPMI::PP::Packet::IPMI::Response::GetSessionChallenge;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(dualvar);

my @fields = (
  { format => 'C', name => 'completion_code' },
  { format => 'N', name => 'session_id' },
  { format => 'a16', name => 'challenge' },
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
  'completion_code' => {
    0 => "Command Completed Successfully",
    0x81 => "Invalid User Name",
    0x82 => "Null User Names Not Enabled",
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
  my $self = shift;
  my $calc = $self->{source_addr} +
             $self->{sequence} +
             ($self->{source_lun} << 2) +
             $self->{command} +
             $self->{completion_code} +
             (($self->{session_id} & 0xff000000) >> 24) +
             (($self->{session_id} & 0x00ff0000) >> 16) +
             (($self->{session_id} & 0x0000ff00) >>  8) +
             (($self->{session_id} & 0x000000ff))
           ;
  for my $byte (unpack "C16", $self->{challenge}){ $calc += $byte; }
  return ($self->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
