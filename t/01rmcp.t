use strict;
use warnings;
use Net::IPMI::PP::Packet::RMCP;

my @warnings;
$SIG{__WARN__} = sub { push @warnings, "@_"; };

use Test::More tests => 5;

# Check for errors
{
  eval 'my $packet = Net::IPMI::PP::Packet::RMCP::new';
  like $@, qr/called with no arguments/, "Croak if ::new called without data";
  eval 'my $packet = Net::IPMI::PP::Packet::RMCP->new';
  like $@, qr/called with no arguments/, "Croak if ->new called without data";

  eval 'my $packet = Net::IPMI::PP::Packet::RMCP::new(1,2);';
  like $@, qr/Too many/, "Croak if ::new called with extra data";
  eval 'my $packet = Net::IPMI::PP::Packet::RMCP->new(1,2);';
  like $@, qr/Too many/, "Croak if ->new called with with extra data";
}

is @warnings, 0, "No warnings";
print @warnings;
