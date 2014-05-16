package Net::IPMI::PP::Packet::IPMI::AuthSession;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

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
sub constants { return \%constants; }

sub generate_md5 {
  # payload is the IPMI request/response in packed form
  my ($self, $pass, $payload) = @_;
  confess "generate_md5 called without a password" unless defined $pass;
  confess "generate_md5 called without a payload" unless defined $payload;
  $pass = pack "Z16", $pass;

  use Digest::MD5 qw(md5);
  return md5(
    $pass .
    pack("N", $self->{session_id}) .
    $payload .
    pack("N", $self->{session_seq}) .
    $pass
  );
}

1;
