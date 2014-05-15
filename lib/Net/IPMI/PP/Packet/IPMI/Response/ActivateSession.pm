package Net::IPMI::PP::Packet::IPMI::Response::ActivateSession;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(dualvar);

my @fields = (
  { format => 'C', name => 'completion_code' },
  { format => 'C', name => 'auth_type_remaining' },
  { format => 'N', name => 'session_id' },
  { format => 'N', name => 'sequence_in' },
  { format => 'C', name => 'max_priv_level' },
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
  'completion_code' => {
    0 => "Command Completed Successfully",
    0x81 => "No Session Slot Available",
    0x82 => "No Slot Available For User",
    0x83 => "No Slot Available For User Due To Max Priv",
    0x84 => "Session Sequence Number Out Of Range",
    0x85 => "Invalid Session Id",
    0x86 => "Privilege Level Too High",
  },
  'auth_type_remaining' => {
    0x00 => 'None',
    0x01 => 'MD2',
    0x02 => 'MD5',
    0x04 => 'Unencrypted',
    0x05 => 'OEM',
  },
  'max_priv_level' => {
    0x01 => 'Callback',
    0x02 => 'User',
    0x03 => 'Operator',
    0x04 => 'Administrator',
    0x05 => 'OEM',
  },
);
sub constant {
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
             $self->{auth_type_remaining} +
             (($self->{session_id} & 0xff000000) >> 24) +
             (($self->{session_id} & 0x00ff0000) >> 16) +
             (($self->{session_id} & 0x0000ff00) >>  8) +
             (($self->{session_id} & 0x000000ff)) +
             (($self->{sequence_in} & 0xff000000) >> 24) +
             (($self->{sequence_in} & 0x00ff0000) >> 16) +
             (($self->{sequence_in} & 0x0000ff00) >>  8) +
             (($self->{sequence_in} & 0x000000ff)) +
             $self->{max_priv_level}
           ;
  return ($self->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
