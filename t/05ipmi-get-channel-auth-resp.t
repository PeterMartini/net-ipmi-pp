use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::IPMI::Session;
use Net::IPMI::PP::Packet::IPMI::Header;
use Net::IPMI::PP::Packet::IPMI::Response;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 65;

{
  my $pkt_rmcp = "\x06\x00\xff\07";
  my $pkt_ipmi_sess = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10";
  my $pkt_ipmi_resp = "\x81\x1c\x63\x20\x04\x38\x00\x01\x06\x14\x00\x00\x00\x00\x00\x89";
  my $data = "${pkt_rmcp}${pkt_ipmi_sess}${pkt_ipmi_resp}";

  (my $rmcp, $data) = Net::IPMI::PP::Packet::RMCP->unpack($data);
  isnt $rmcp, undef, "A rmcp was returned";
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
  is "$session->{auth_type}", "NONE", "\"auth_type\" is NONE";
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
  is ref $response, "Net::IPMI::PP::Packet::IPMI::Response::GetChannelAuth", "Returned the right type";
  is $response->{source_addr}, 0x20, "source_addr is 0x20";
  is $response->{sequence}, 0, "sequence is 0";
  is $response->{source_lun}, 0x01, "source_lun is 0x01";
  is $response->{command}+0, 0x38, "command+0 is 0x38";
  is "$response->{command}", "Get Channel Authentication Capabilities",
    "\"command\" is Get Channel Authentication Capabilities";
  is $response->{completion_code}+0, 0, "completion_code+0 is 0";
  is "$response->{completion_code}", "Command Completed Successfully",
    "\"completion_code\" is Command Completed Successfully";
  is $response->{channel}, 0x01, "channel is 0x01";
  is $response->{contains_v20_data}+0, 0, "contains_v20_data+0 is 0";
  is "$response->{contains_v20_data}", "False", "\"contains_v20_data\" is False";
  is $response->{unknown_1}, 0, "unknown_1 is 0";
  is $response->{auth_oem}+0, 0, "auth_oem+0 is 0";
  is "$response->{auth_oem}", "Not Supported", "\"auth_oem\" is Not Supported";
  is $response->{auth_unencrypted}+0, 0, "auth_unencrypted+0 is 0";
  is "$response->{auth_unencrypted}", "Not Supported", "\"auth_unencrypted\" is Not Supported";
  is $response->{unknown_2}, 0, "unknown_2 is 0";
  is $response->{auth_md5}+0, 1, "auth_md5+0 is 0";
  is "$response->{auth_md5}", "Supported", "\"auth_md5\" is Supported";
  is $response->{auth_md2}+0, 1, "auth_md2+0 is 0";
  is "$response->{auth_md2}", "Supported", "\"auth_md2\" is Supported";
  is $response->{auth_none}+0, 0, "auth_none+0 is 0";
  is "$response->{auth_none}", "Not Supported", "\"auth_none\" is Not Supported";
  is $response->{unknown_3}, 0, "unknown_3 is 0";
  is $response->{kg_status}+0, 0, "kg_status+0 is 0";
  is "$response->{kg_status}", "Use KG", "\"kg_status\" is Use KG";
  is $response->{per_message_auth}+0, 1, "per_message_auth+0 is 0";
  is "$response->{per_message_auth}", "Disabled", "\"per_message_auth\" is Disabled";
  is $response->{user_level_auth}+0, 0, "user_level_auth+0 is 0";
  is "$response->{user_level_auth}", "Enabled", "\"user_level_auth\" is Enabled";
  is $response->{non_null_usernames}+0, 1, "non_null_usernames+0 is 0";
  is "$response->{non_null_usernames}", "True", "\"non_null_usernames\" is True";
  is $response->{null_usernames}+0, 0, "null_usernames+0 is 0";
  is "$response->{null_usernames}", "False", "\"null_usernames\" is False";
  is $response->{anon_login_enabled}+0, 0, "anon_login_enabled+0 is 0";
  is "$response->{anon_login_enabled}", "False", "\"anon_login_enabled\" is False";
  # For v20_supported and v15_supported, technically they're reserved,
  # since contains_v20_data is false...
  is $response->{v20_supported}+0, 0, "v20_supported+0 is 0";
  is "$response->{v20_supported}", "False", "\"v20_supported\" is False";
  is $response->{v15_supported}+0, 0, "v15_supported+0 is 0";
  is "$response->{v15_supported}", "False", "\"v15_supported\" is False";
  is $response->{oem_id}, "\x00\x00\x00", "oem_id is \\x00\\x00\\x00";
  is $response->{oem_aux_data}, 0x00, "oem_id is 0x00";
  is $response->{checksum}, 0x89, "data_checksum is 0x89";
  is $response->is_valid_checksum, 1, "Checksum is valid";
}

is $warnings, undef, "No warnings";
