use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 8;

{
  my $data = "\x06\x00\xff\x06\x00\x00\x11\xbe\x80\x00\x00\x00";
  my $packet = Net::IPMI::PP::Packet::RMCP::new($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{header}{ver}, 6, "Version is 6 (RMCP_VERSION_1)";
  is $packet->{header}{reserved}, 0, "Reserved is 0";
  is $packet->{header}{sequence}, 255, "Sequence is 255";
  is $packet->{header}{classid}, 6, "classid is 6 (ASF)";
  is $packet->{payload}, substr($data,4), "The payload is everything but the first 4 bytes";
}

is $warnings, undef, "No warnings";
