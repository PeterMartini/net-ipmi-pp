use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;

my @warnings;
$SIG{__WARN__} = sub { push @warnings, "@_"; };

use Test::More tests => 47;

# Check for errors
{
  eval 'my $packet = Net::IPMI::PP::Packet::RMCP->unpack';
  like $@, qr/Insufficient arguments/, "Croak if ->unpack called without data";

  eval 'my $packet = Net::IPMI::PP::Packet::RMCP->unpack(1,2);';
  like $@, qr/could not decode/, "Croak if ->unpack called with with extra data";
}

# Constants tests

# Test RMCP_VERSION_1 + ASF
{
  my $data = "\x06\x00\xff\x06\x39";

  (my $packet, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{ver}+0, 6, "version+0 is 6";
  is "$packet->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{reserved}, 0, "Reserved is 0";
  is $packet->{sequence}, 255, "Sequence is 255";
  is $packet->{classid}+0, 6, "classid+0 is 6";
  is "$packet->{classid}", "ASF", "\"classid\" is ASF";
  is $data, 9, "The payload is what's expected";
}

# Test UNKNOWN version + ASF
{
  my $data = "\xff\x00\xff\x06\x39";
  (my $packet, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{ver}+0, 255, "version+0 is 255";
  is "$packet->{ver}", "UNKNOWN", "\"version\" is UNKNOWN";
  is $packet->{reserved}, 0, "Reserved is 0";
  is $packet->{sequence}, 255, "Sequence is 255";
  is $packet->{classid}+0, 6, "classid+0 is 6";
  is "$packet->{classid}", "ASF", "\"classid\" is ASF";
  is $data, 9, "The payload is what's expected";
}

# Test RMCP_VERSION_1 + IPMI
{
  my $data = "\x06\x00\xff\x07\x39";
  (my $packet, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{ver}+0, 6, "version+0 is 6";
  is "$packet->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{reserved}, 0, "Reserved is 0";
  is $packet->{sequence}, 255, "Sequence is 255";
  is $packet->{classid}+0, 7, "classid+0 is 7";
  is "$packet->{classid}", "IPMI", "\"classid\" is IPMI";
  is $data, 9, "The payload is what's expected";
}

# Test RMCP_VERSION_1 + OEM
{
  my $data = "\x06\x00\xff\x08\x39";
  (my $packet, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{ver}+0, 6, "version+0 is 6";
  is "$packet->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{reserved}, 0, "Reserved is 0";
  is $packet->{sequence}, 255, "Sequence is 255";
  is $packet->{classid}+0, 8, "classid+0 is 8";
  is "$packet->{classid}", "OEM", "\"classid\" is OEM";
  is $data, 9, "The payload is what's expected";
}

# Test RMCP_VERSION_1 + UNKNOWN
{
  my $data = "\x06\x00\xff\xff\x39";
  (my $packet, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{ver}+0, 6, "version+0 is 6";
  is "$packet->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{reserved}, 0, "Reserved is 0";
  is $packet->{sequence}, 255, "Sequence is 255";
  is $packet->{classid}+0, 255, "classid+0 is 255";
  is "$packet->{classid}", "UNKNOWN", "\"classid\" is UNKNOWN";
  is $data, 9, "The payload is what's expected";
}

