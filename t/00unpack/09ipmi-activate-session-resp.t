use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::IPMI::AuthSession;
use Net::IPMI::PP::Packet::IPMI::Header;
use Net::IPMI::PP::Packet::IPMI::Response;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 38;

{
  my $pkt_rmcp = "\x06\x00\xff\07";
  my $pkt_ipmi_sess = "\x02\x36\x97\x77\x2a\x00\x0e\x00\x02" .
                      "\x7a\xdc\x7c\x53\x08\x3c\xbf\xc4\xa1\x47\xef\x01\xf5\xe1\x0b\x24" .
                      "\x12"
                    ;
  my $pkt_ipmi_resp = "\x81\x1c\x63\x20\x0c\x3a" .
                      "\x00\x00\x00\x0f\x00\x02\x01\x00\x00\x00\x04\x84"
                    ;
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

  (my $session, $data) = Net::IPMI::PP::Packet::IPMI::AuthSession->unpack($data);
  is $session->{auth_type}+0, 2, "auth_type+0 is 0";
  is "$session->{auth_type}", "MD5", "\"auth_type\" is MD5";
  is $session->{session_seq}, 0x3697772a, "session_seq is 0x3697772a";
  is $session->{session_id}, 0x000e0002, "session_id is 0x000e0002";
  is $session->{auth_code}, "\x7a\xdc\x7c\x53\x08\x3c\xbf\xc4\xa1\x47\xef\x01\xf5\xe1\x0b\x24",
    "auth_code is right";
  is $session->generate_md5("test", $data), $session->{auth_code}, "Password matches";
  is $session->{len}, 0x12, "len is 0x12";
  is $data, $pkt_ipmi_resp, "The payload is the IPMI response";

  (my $header, $data) = Net::IPMI::PP::Packet::IPMI::Header->unpack($data);
  is $header->{target_addr}, 0x81, "target_addr is 0x81";
  is $header->{target_lun}, 0, "target_lun is 0";
  is $header->{target_netfn}+0, 7, "target_netfn+0 is 7";
  is "$header->{target_netfn}", "Application Response",
    "\"target_netfn\" is Application Request";
  is $header->{checksum}, 0x63, "checksum is 0x63";

  (my $response, $data) = Net::IPMI::PP::Packet::IPMI::Response->unpack($data);
  is ref $response, "Net::IPMI::PP::Packet::IPMI::Response::ActivateSession", "Returned the right type";
  is $response->{source_addr}, 0x20, "source_addr is 0x20";
  is $response->{sequence}, 0, "sequence is 0";
  is $response->{source_lun}, 0x03, "source_lun is 0x03";
  is $response->{command}+0, 0x3a, "command+0 is 0x3a";
  is "$response->{command}", "Activate Session",
    "\"command\" is Activate Session";
  is $response->{completion_code}+0, 0, "completion_code+0 is 0";
  is "$response->{completion_code}", "Command Completed Successfully",
    "\"completion_code\" is Command Completed Successfully";
  is $response->{auth_type_remaining}+0, 0, "auth_type_remaining+0 is 0";
  is "$response->{auth_type_remaining}", "None", "\"auth_type_remaining\" is None";
  is $response->{session_id}, 0x000f0002, "sequence is 0x000f0002";
  is $response->{sequence_in}, 0x01000000, "sequence is 0x01000000";
  is $response->{max_priv_level}+0, 4, "max_priv_level+0 is 4";
  is "$response->{max_priv_level}", "Administrator", "\"max_priv_level\" is Administrator";

  is $response->is_valid_checksum, 1, "Checksum is valid";
}

is $warnings, undef, "No warnings";
