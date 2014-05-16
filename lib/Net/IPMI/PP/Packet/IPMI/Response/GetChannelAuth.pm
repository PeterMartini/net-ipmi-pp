package Net::IPMI::PP::Packet::IPMI::Response::GetChannelAuth;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp qw(confess);

my @fields = (
  { format => 'C', name => 'completion_code' },
  { format => 'C', name => 'channel' },
  { format => 'C', name => {
    'contains_v20_data'=> { mask => 0b10000000, shift => 7 },
    'unknown_1'        => { mask => 0b01000000, shift => 6 },
    'auth_oem'         => { mask => 0b00100000, shift => 5 },
    'auth_unencrypted' => { mask => 0b00010000, shift => 4 },
    'unknown_2'        => { mask => 0b00001000, shift => 3 },
    'auth_md5'         => { mask => 0b00000100, shift => 2 },
    'auth_md2'         => { mask => 0b00000010, shift => 1 },
    'auth_none'        => { mask => 0b00000001, shift => 0 },
    }},
  { format => 'C', name => {
    'unknown_3'          => { mask => 0b11000000, shift => 6 },
    'kg_status'          => { mask => 0b00100000, shift => 5 },
    'per_message_auth'   => { mask => 0b00010000, shift => 4 },
    'user_level_auth'    => { mask => 0b00001000, shift => 3 },
    'non_null_usernames' => { mask => 0b00000100, shift => 2 },
    'null_usernames'     => { mask => 0b00000010, shift => 1 },
    'anon_login_enabled' => { mask => 0b00000001, shift => 0 },
    }},
  { format => 'C', name => {
    'unknown_4'     => { mask => 0b11111100, shift => 2 },
    'v20_supported' => { mask => 0b00000010, shift => 1 },
    'v15_supported' => { mask => 0b00000001, shift => 0 },
    }},
  { format => 'a3', name => 'oem_id' },
  { format => 'C', name => 'oem_aux_data' },
  { format => 'C', name => 'checksum' },
);
sub fields { return \@fields; }

my %constants = (
  'completion_code' => {
    0 => "Command Completed Successfully",
  },
  'auth_oem' => { 0 => 'Not Supported', 1 => 'Supported' },
  'auth_unencrypted' => { 0 => 'Not Supported', 1 => 'Supported' },
  'auth_md5' => { 0 => 'Not Supported', 1 => 'Supported' },
  'auth_md2' => { 0 => 'Not Supported', 1 => 'Supported' },
  'auth_none' => { 0 => 'Not Supported', 1 => 'Supported' },
  'kg_status' => { 0 => 'Use KG', 1 => 'Use KUID' },
  'per_message_auth' => { 0 => 'Enabled', 1 => 'Disabled' },
  'user_level_auth' =>  { 0 => 'Enabled', 1 => 'Disabled' },
  'non_null_usernames' => { 0 => 'False', 1 => 'True' },
  'null_usernames' => { 0 => 'False', 1 => 'True' },
  'anon_login_enabled' => { 0 => 'False', 1 => 'True' },
  'contains_v20_data' => { 0 => 'False', 1 => 'True' },
  'v20_supported' => { 0 => 'False', 1 => 'True' },
  'v15_supported' => { 0 => 'False', 1 => 'True' },
);
sub constants { return \%constants; }

sub is_valid_checksum {
  my $self = shift;
  my @oem = unpack "C3", $self->{oem_id};
  my $calc = $self->{source_addr} +
             $self->{sequence} +
             ($self->{source_lun} << 2) +
             $self->{command} +
             $self->{completion_code} +
             $self->{channel} +
             ($self->{contains_v20_data} << 7) +
             ($self->{unknown_1} << 6) +
             ($self->{auth_oem} << 5) +
             ($self->{auth_unencrypted} << 4) +
             ($self->{unknown_2} << 3) +
             ($self->{auth_md5} << 2) +
             ($self->{auth_md2} << 1) +
             $self->{auth_none} +
             ($self->{unknown_3} << 6) +
             ($self->{kg_status} << 5) +
             ($self->{per_message_auth} << 4) +
             ($self->{user_level_auth} << 3) +
             ($self->{non_null_usernames} << 2) +
             ($self->{null_usernames} << 1) +
             $self->{anon_login_enabled} +
             ($self->{unknown_4} << 2) +
             ($self->{v20_supported} << 1) +
             $self->{v15_supported} +
             $oem[0] +
             $oem[1] +
             $oem[2] +
             $self->{oem_aux_data}
           ;
  return ($self->{checksum} == (0x100 - ($calc & 0xff)));
}

1;
