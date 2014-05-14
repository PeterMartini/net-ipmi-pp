use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::IPMI::Session;
use Net::IPMI::PP::Packet::IPMI::Header;
use Net::IPMI::PP::Packet::IPMI::Request;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 36;

{
  my $pkt_rmcp = "\x06\x00\xff\07";
  my $pkt_ipmi_sess = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x09";
  my $pkt_ipmi_req = "\x20\x18\xc8\x81\x04\x38\x0e\x04\x31";
  my $data = "${pkt_rmcp}${pkt_ipmi_sess}${pkt_ipmi_req}";

  (my $rmcp, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $rmcp, undef, "An RMCP packet was returned";
  is ref $rmcp, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $rmcp->{ver}+0, 6, "version+0 is 6";
  is "$rmcp->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $rmcp->{reserved}, 0, "reserved is 0";
  is $rmcp->{sequence}, 255, "sequence is 255";
  is $rmcp->{classid}+0, 7, "classid+0 is 7";
  is "$rmcp->{classid}", "IPMI", "\"classid\" is IPMI";
  is $data, $pkt_ipmi_sess.$pkt_ipmi_req, "The payload is the IPMI Session";

  (my $session, $data) = Net::IPMI::PP::Packet::IPMI::Session->unpack($data);
  is $session->{auth_type}+0, 0, "iana+0 is 4542";
  is "$session->{auth_type}", "NONE", "\"auth_type\" is NONE";
  is $session->{session_seq}, 0, "session_seq is 0";
  is $session->{session_id}, 0, "session_id is 0";
  is $session->{len}, 9, "len is 9";
  is $data, $pkt_ipmi_req, "The payload is the IPMI request";

  (my $header, $data) = Net::IPMI::PP::Packet::IPMI::Header->unpack($data);
  is $header->{target_addr}, 0x20, "target_addr is 0x20";
  is $header->{target_lun}, 0, "target_lun is 0";
  is $header->{target_netfn}+0, 6, "target_netfn+0 is 6";
  is "$header->{target_netfn}", "Application Request",
    "\"target_netfn\" is Application Request";
  is $header->{checksum}, 0xc8, "checksum is 0xc8";

  (my $request, $data) = Net::IPMI::PP::Packet::IPMI::Request->unpack($data);
  is ref $request, "Net::IPMI::PP::Packet::IPMI::Request::GetChannelAuth", "Returned the right type";
  is $request->{source_addr}, 0x81, "source_addr is 0x81";
  is $request->{sequence}, 0, "sequence is 0";
  is $request->{source_lun}, 0x01, "source_lun is 0x01";
  is $request->{command}+0, 0x38, "command+0 is 0x38";
  is "$request->{command}", "Get Channel Authentication Capabilities",
    "\"command\" is Get Channel Authentication Capabilities";
  is $request->{v15_compatible}, 0x0, "v15_compatible is false";
  is $request->{unknown_1}, 0, "unknown_1 is 0";
  is $request->{channel}+0, 0x0e, "channel+0 is 0x0e";
  is "$request->{channel}", "Current", "\"channel\" is Current";
  is $request->{unknown_2}, 0, "unknown_2 is 0";
  is $request->{priv_level}+0, 0x04, "priv_level+0 is 0x04";
  is "$request->{priv_level}", "Administrator", "\"priv_level\" is Administrator";
  is $request->{checksum}, 0x31, "data_checksum is 0x31";
  is $request->is_valid_checksum, 1, "Checksum is valid";
}

is $warnings, undef, "No warnings";
