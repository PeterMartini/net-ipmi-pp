use strict;
use warnings;
use Net::IPMI::PP::Packet::ASF::Pong;

my $warnings = 0;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 4;

{
  my $expected = "\x00\x00\x11\xbe\x00\x00\x00\x00\x81\x00\x00\x00\x00\x00\x00\x00";
  my $rmcp = bless {
    iana => 4542,
    entities => 0x81,
  }, "Net::IPMI::PP::Packet::ASF::Pong";

  my $observed = $rmcp->pack;
  isnt $observed, undef, "A packet was returned";
  is ref $observed, "", "Not an object";
  is $observed, $expected, "Packed as expected";
}

is $warnings, 0, "No warnings";
