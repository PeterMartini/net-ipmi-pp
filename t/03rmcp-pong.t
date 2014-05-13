use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::ASF;
use Net::IPMI::PP::Packet::ASF::Pong;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 24;

{
  my $data = "\x06\x00\xff\x06" .
             "\x00\x00\x11\xbe\x40\x00\x00\x10" .
             "\x00\x00\x11\xbe\x00\x00\x00\x00\x81\x00\x00\x00\x00\x00\x00\x00";
  (my $rmcp, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $rmcp, undef, "An RMCP packet was returned";
  is ref $rmcp, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $rmcp->{ver}+0, 6, "version+0 is 6";
  is "$rmcp->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $rmcp->{reserved}, 0, "reserved is 0";
  is $rmcp->{sequence}, 255, "sequence is 255";
  is $rmcp->{classid}+0, 6, "classid+0 is 6";
  is "$rmcp->{classid}", "ASF", "\"classid\" is ASF";
  is length($data), 24, "The payload is everything but the first 4 bytes";

  (my $asf, $data) = Net::IPMI::PP::Packet::ASF->unpack($data);
  is $asf->{iana}+0, 4542, "iana+0 is 4542";
  is "$asf->{iana}", "Alerting Specifications Forum (ASF)", "\"iana\" is ... (ASF)";
  is $asf->{type}+0, 0x40, "type+0 is 0x40";
  is "$asf->{type}", "PONG", "\"type\" is PONG";
  is $asf->{tag}, 0, "tag is 0";
  is $asf->{reserved}, 0, "reserved is 0";
  is $asf->{len}, 16, "len is 16";

  (my $pong, $data) = Net::IPMI::PP::Packet::ASF::Pong->unpack($data);
  is $pong->{iana}+0, 4542, "iana+0 is 4542";
  is "$pong->{iana}", "Alerting Specifications Forum (ASF)", "\"iana\" is ... (ASF)";
  is $pong->{oem}, 0, "oem is 0";
  is $pong->{entities}, 0x81, "entities is 0x81";
  is $pong->{interactions}, 0, "interactions is 0";
  is $pong->{reserved}, "\x00\x00\x00\x00\x00\x00", "reserved is 6 NULL bytes";
  is $data, "", "payload is an empty string";
}

is $warnings, undef, "No warnings";
