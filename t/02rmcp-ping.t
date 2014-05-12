use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::ASF;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 17;

{
  my $data = "\x06\x00\xff\x06\x00\x00\x11\xbe\x80\x00\x00\x00";
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
  is $asf->{header}{type}+0, 0x80, "type+0 is 0x80";
  is "$asf->{header}{type}", "PING", "\"type\" is PING";
  is $asf->{header}{tag}, 0, "tag is 0";
  is $asf->{header}{reserved}, 0, "reserved is 0";
  is $asf->{header}{len}, 0, "len is 0";
}

is $warnings, undef, "No warnings";
