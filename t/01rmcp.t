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
  my $packet = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{header}{ver}+0, 6, "version+0 is 6";
  is "$packet->{header}{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{header}{reserved}, 0, "Reserved is 0";
  is $packet->{header}{sequence}, 255, "Sequence is 255";
  is $packet->{header}{classid}+0, 6, "classid+0 is 6";
  is "$packet->{header}{classid}", "ASF", "\"classid\" is ASF";
  is $packet->{payload}, 9, "The payload is what's expected";
}

# Test UNKNOWN version + ASF
{
  my $data = "\xff\x00\xff\x06\x39";
  my $packet = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{header}{ver}+0, 255, "version+0 is 255";
  is "$packet->{header}{ver}", "UNKNOWN", "\"version\" is UNKNOWN";
  is $packet->{header}{reserved}, 0, "Reserved is 0";
  is $packet->{header}{sequence}, 255, "Sequence is 255";
  is $packet->{header}{classid}+0, 6, "classid+0 is 6";
  is "$packet->{header}{classid}", "ASF", "\"classid\" is ASF";
  is $packet->{payload}, 9, "The payload is what's expected";
}

# Test RMCP_VERSION_1 + IPMI
{
  my $data = "\x06\x00\xff\x07\x39";
  my $packet = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{header}{ver}+0, 6, "version+0 is 6";
  is "$packet->{header}{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{header}{reserved}, 0, "Reserved is 0";
  is $packet->{header}{sequence}, 255, "Sequence is 255";
  is $packet->{header}{classid}+0, 7, "classid+0 is 7";
  is "$packet->{header}{classid}", "IPMI", "\"classid\" is IPMI";
  is $packet->{payload}, 9, "The payload is what's expected";
}

# Test RMCP_VERSION_1 + OEM
{
  my $data = "\x06\x00\xff\x08\x39";
  my $packet = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{header}{ver}+0, 6, "version+0 is 6";
  is "$packet->{header}{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{header}{reserved}, 0, "Reserved is 0";
  is $packet->{header}{sequence}, 255, "Sequence is 255";
  is $packet->{header}{classid}+0, 8, "classid+0 is 8";
  is "$packet->{header}{classid}", "OEM", "\"classid\" is OEM";
  is $packet->{payload}, 9, "The payload is what's expected";
}

# Test RMCP_VERSION_1 + UNKNOWN
{
  my $data = "\x06\x00\xff\xff\x39";
  my $packet = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $packet, undef, "A packet was returned";
  is ref $packet, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $packet->{header}{ver}+0, 6, "version+0 is 6";
  is "$packet->{header}{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $packet->{header}{reserved}, 0, "Reserved is 0";
  is $packet->{header}{sequence}, 255, "Sequence is 255";
  is $packet->{header}{classid}+0, 255, "classid+0 is 255";
  is "$packet->{header}{classid}", "UNKNOWN", "\"classid\" is UNKNOWN";
  is $packet->{payload}, 9, "The payload is what's expected";
}

