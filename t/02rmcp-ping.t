use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::ASF;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 17;

{
  my $data = "\x06\x00\xff\x06\x00\x00\x11\xbe\x80\x00\x00\x00";
  (my $rmcp, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $rmcp, undef, "A rmcp was returned";
  is ref $rmcp, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $rmcp->{ver}+0, 6, "version+0 is 6";
  is "$rmcp->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $rmcp->{reserved}, 0, "reserved is 0";
  is $rmcp->{sequence}, 255, "sequence is 255";
  is $rmcp->{classid}+0, 6, "classid+0 is 6";
  is "$rmcp->{classid}", "ASF", "\"classid\" is ASF";
  is length($data), 8, "The payload is everything but the first 4 bytes";

  (my $asf, $data) = Net::IPMI::PP::Packet::ASF->unpack($data);
  is $asf->{iana}+0, 4542, "iana+0 is 4542";
  is "$asf->{iana}", "Alerting Specifications Forum (ASF)", "\"iana\" is ... (ASF)";
  is $asf->{type}+0, 0x80, "type+0 is 0x80";
  is "$asf->{type}", "PING", "\"type\" is PING";
  is $asf->{tag}, 0, "tag is 0";
  is $asf->{reserved}, 0, "reserved is 0";
  is $asf->{len}, 0, "len is 0";
}

is $warnings, undef, "No warnings";
