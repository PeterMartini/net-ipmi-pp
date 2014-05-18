use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;

my $warnings = 0;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 4;

{
  my $expected = "\x06\x00\xff\x06";
  my $rmcp = bless {
    ver => 6,
    sequence => 255,
    classid => 6
  }, "Net::IPMI::PP::Packet::RMCP";

  my $observed = $rmcp->pack;
  isnt $observed, undef, "A packet was returned";
  is ref $observed, "", "Not an object";
  is $observed, $expected, "Packed as expected";
}

is $warnings, 0, "No warnings";
