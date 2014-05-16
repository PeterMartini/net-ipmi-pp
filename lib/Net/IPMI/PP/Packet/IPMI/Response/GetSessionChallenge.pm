package Net::IPMI::PP::Packet::IPMI::Response::GetSessionChallenge;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

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
sub constants { return \%constants; }

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
