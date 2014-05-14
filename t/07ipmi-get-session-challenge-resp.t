use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::IPMI::Session;
use Net::IPMI::PP::Packet::IPMI::Header;
use Net::IPMI::PP::Packet::IPMI::Response;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 32;

{
  my $pkt_rmcp = "\x06\x00\xff\07";
  my $pkt_ipmi_sess = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10";
  my $pkt_ipmi_resp = "\x81\x1c\x63\x20\x08\x39" .
                      "\x00\x00\x0e\x00\x02\x71\x0a\x48\x53\x16\x89\xa1\xac\x9a\xd6\x33\x05\x13\x1d\x67\x64\xea";
  my $data = "${pkt_rmcp}${pkt_ipmi_sess}${pkt_ipmi_resp}";

  (my $rmcp, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $rmcp, undef, "An RMCP packet was returned";
  is ref $rmcp, "Net::IPMI::PP::Packet::RMCP", "And its the right type";
  is $rmcp->{ver}+0, 6, "version+0 is 6";
  is "$rmcp->{ver}", "RMCP_VERSION_1", "\"version\" is RMCP_VERSION_1";
  is $rmcp->{reserved}, 0, "reserved is 0";
  is $rmcp->{sequence}, 255, "sequence is 255";
  is $rmcp->{classid}+0, 7, "classid+0 is 7";
  is "$rmcp->{classid}", "IPMI", "\"classid\" is IPMI";
  is $data, $pkt_ipmi_sess.$pkt_ipmi_resp, "The payload is the IPMI Session";

  (my $session, $data) = Net::IPMI::PP::Packet::IPMI::Session->unpack($data);
  is $session->{auth_type}+0, 0, "iana+0 is 4542";
  is "$session->{auth_type}", "None", "\"auth_type\" is None";
  is $session->{session_seq}, 0, "session_seq is 0";
  is $session->{session_id}, 0, "session_id is 0";
  is $session->{len}, 0x10, "len is 0x10";
  is $data, $pkt_ipmi_resp, "The payload is the IPMI response";

  (my $header, $data) = Net::IPMI::PP::Packet::IPMI::Header->unpack($data);
  is $header->{target_addr}, 0x81, "target_addr is 0x81";
  is $header->{target_lun}, 0, "target_lun is 0";
  is $header->{target_netfn}+0, 7, "target_netfn+0 is 7";
  is "$header->{target_netfn}", "Application Response",
    "\"target_netfn\" is Application Request";
  is $header->{checksum}, 0x63, "checksum is 0x63";

  (my $response, $data) = Net::IPMI::PP::Packet::IPMI::Response->unpack($data);
  is ref $response, "Net::IPMI::PP::Packet::IPMI::Response::GetSessionChallenge", "Returned the right type";
  is $response->{source_addr}, 0x20, "source_addr is 0x20";
  is $response->{sequence}, 0, "sequence is 0";
  is $response->{source_lun}, 0x02, "source_lun is 0x02";
  is $response->{command}+0, 0x39, "command+0 is 0x39";
  is "$response->{command}", "Get Session Challenge",
    "\"command\" is Get Session Challenge";
  is $response->{completion_code}+0, 0, "completion_code+0 is 0";
  is "$response->{completion_code}", "Command Completed Successfully",
    "\"completion_code\" is Command Completed Successfully";
  is $response->{session_id}, 0x000e0002, "session_id is 0x000e0002";
  is $response->{challenge}, "\x71\x0a\x48\x53\x16\x89\xa1\xac\x9a\xd6\x33\x05\x13\x1d\x67\x64",
    "challenge is correct";

  is $response->is_valid_checksum, 1, "Checksum is valid";
}

is $warnings, undef, "No warnings";
