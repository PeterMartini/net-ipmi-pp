use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;
use Net::IPMI::PP::Packet::IPMI::AuthSession;
use Net::IPMI::PP::Packet::IPMI::Header;
use Net::IPMI::PP::Packet::IPMI::Request;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 35;

{
  my $pkt_rmcp = "\x06\x00\xff\07";
  my $pkt_ipmi_sess = "\x02\x00\x00\x00\x00\x00\x0e\x00\x02" .
                      "\xfb\xb6\x4d\x63\x53\x6c\x8a\x4f\xb0\x2d\x9e\x51\x5f\x77\xcb\x29" .
                      "\x1d"
                    ;
  my $pkt_ipmi_req = "\x20\x18\xc8\x81\x0c\x3a\x02\x04\x71" .
                     "\x0a\x48\x53\x16\x89\xa1\xac\x9a\xd6\x33" .
                     "\x05\x13\x1d\x67\x64\x36\x97\x77\x2a\x20"
                   ;
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

  (my $session, $data) = Net::IPMI::PP::Packet::IPMI::AuthSession->unpack($data);
  is $session->{auth_type}+0, 2, "auth_type+0 is 2";
  is "$session->{auth_type}", "MD5", "\"auth_type\" is MD5";
  is $session->{session_seq}, 0, "session_seq is 0";
  is $session->{session_id}, 0x000e0002, "session_id is 0x000e0002";
  is $session->{auth_code}, "\xfb\xb6\x4d\x63\x53\x6c\x8a\x4f\xb0\x2d\x9e\x51\x5f\x77\xcb\x29",
    "Auth Code properly unpacked";
  is $session->{len}, 0x1d, "len is 0x1d";
  is $data, $pkt_ipmi_req, "The payload is the IPMI request";

  (my $header, $data) = Net::IPMI::PP::Packet::IPMI::Header->unpack($data);
  is $header->{target_addr}, 0x20, "target_addr is 0x20";
  is $header->{target_lun}, 0, "target_lun is 0";
  is $header->{target_netfn}+0, 6, "target_netfn+0 is 6";
  is "$header->{target_netfn}", "Application Request",
    "\"target_netfn\" is Application Request";
  is $header->{checksum}, 0xc8, "checksum is 0xc8";

  (my $request, $data) = Net::IPMI::PP::Packet::IPMI::Request->unpack($data);
  is ref $request, "Net::IPMI::PP::Packet::IPMI::Request::ActivateSession", "Returned the right type";
  is $request->{source_addr}, 0x81, "source_addr is 0x81";
  is $request->{sequence}, 0, "sequence is 0";
  is $request->{source_lun}, 0x03, "source_lun is 0x03";
  is $request->{command}+0, 0x3a, "command+0 is 0x3a";
  is "$request->{command}", "Activate Session",
    "\"command\" is Activate Session";
  is $request->{auth_type}+0, 0x02, "auth_type+0 is 0x02";
  is "$request->{auth_type}", "MD5", "\"auth_type\" is MD5";
  is $request->{priv_level}+0, 0x04, "priv_level+0 is 0x04";
  is "$request->{priv_level}", "Administrator", "\"priv_level\" is Administrator";
  is $request->{challenge}, "\x71\x0a\x48\x53\x16\x89\xa1\xac\x9a\xd6\x33\x05\x13\x1d\x67\x64",
    "challenge is right";
  is $request->{new_sequence}, 0x3697772a, "sequence is 0x3697772a";
  is $request->is_valid_checksum, 1, "Checksum is valid";
}

is $warnings, undef, "No warnings";
