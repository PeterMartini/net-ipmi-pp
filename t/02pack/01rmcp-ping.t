use strict;
use warnings;
use Net::IPMI::PP::Packet::ASF;

my $warnings = 0;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 4;

{
  my $expected = "\x00\x00\x11\xbe\x80\x00\x00\x00";
  my $rmcp = bless {
    iana => 4542,
    type => 0x80,
  }, "Net::IPMI::PP::Packet::ASF";

  my $observed = $rmcp->pack;
  isnt $observed, undef, "A packet was returned";
  is ref $observed, "", "Not an object";
  is $observed, $expected, "Packed as expected";
}

is $warnings, 0, "No warnings";
