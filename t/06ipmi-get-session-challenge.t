use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::IPMI::Session;
use Net::IPMI::PP::Packet::IPMI::Header;
use Net::IPMI::PP::Packet::IPMI::Request;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 31;

{
  my $pkt_rmcp = "\x06\x00\xff\07";
  my $pkt_ipmi_sess = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x09";
  my $pkt_ipmi_req = "\x20\x18\xc8\x81\x08\x39" . "\x02root" . ("\x00" x 12) . "\x78";
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
  is ref $request, "Net::IPMI::PP::Packet::IPMI::Request::GetSessionChallenge", "Returned the right type";
  is $request->{source_addr}, 0x81, "source_addr is 0x81";
  is $request->{sequence}, 0, "sequence is 0";
  is $request->{source_lun}, 0x02, "source_lun is 0x02";
  is $request->{command}+0, 0x39, "command+0 is 0x39";
  is "$request->{command}", "Get Session Challenge",
    "\"command\" is Get Session Challenge";
  is $request->{auth_type}+0, 0x02, "auth_type+0 is 0x02";
  is "$request->{auth_type}", "MD5", "\"auth_type\" is MD5";
  is $request->{user}, "root\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", "user is root";
  is $request->is_valid_checksum, 1, "Checksum is valid";
}

is $warnings, undef, "No warnings";
