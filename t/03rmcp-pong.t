use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::ASF;
use Net::IPMI::PP::Packet::ASF::Pong;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 24;

{
  my $data = "\x06\x00\xff\x06\x00\x00\x11\xbe\x40\x00\x00\x10\x00\x00\x11\xbe\x00\x00\x00\x00\x81\x00\x00\x00\x00\x00\x00\x00";
  my $rmcp = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $rmcp, undef, "A rmcp was returned";
  is ref $rmcp, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $rmcp->{header}{ver}+0, 6, "version+0 is 6";
  is "$rmcp->{header}{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $rmcp->{header}{reserved}, 0, "reserved is 0";
  is $rmcp->{header}{sequence}, 255, "sequence is 255";
  is $rmcp->{header}{classid}+0, 6, "classid+0 is 6";
  is "$rmcp->{header}{classid}", "ASF", "\"classid\" is ASF";
  is $rmcp->{payload}, substr($data,4), "The payload is everything but the first 4 bytes";

  my $asf = Net::IPMI::PP::Packet::ASF->unpack($rmcp->{payload});
  is $asf->{header}{iana}+0, 4542, "iana+0 is 4542";
  is "$asf->{header}{iana}", "Alerting Specifications Forum (ASF)", "\"iana\" is ... (ASF)";
  is $asf->{header}{type}+0, 0x40, "type+0 is 0x40";
  is "$asf->{header}{type}", "PONG", "\"type\" is PONG";
  is $asf->{header}{tag}, 0, "tag is 0";
  is $asf->{header}{reserved}, 0, "reserved is 0";
  is $asf->{header}{len}, 16, "len is 16";

  my $pong = Net::IPMI::PP::Packet::ASF::Pong->unpack($asf->{payload});
  is $pong->{header}{iana}+0, 4542, "iana+0 is 4542";
  is "$pong->{header}{iana}", "Alerting Specifications Forum (ASF)", "\"iana\" is ... (ASF)";
  is $pong->{header}{oem}, 0, "oem is 0";
  is $pong->{header}{entities}, 0x81, "entities is 0x81";
  is $pong->{header}{interactions}, 0, "interactions is 0";
  is $pong->{header}{reserved}, "\x00\x00\x00\x00\x00\x00", "reserved is 6 NULL bytes";
  is $pong->{payload}, "", "payload is an empty string";
}

is $warnings, undef, "No warnings";
