use strict;
use warnings;

my $warnings;
$SIG{__WARN__} = sub { $warnings++; };

use Test::More tests => 2;

BEGIN { use_ok("Net::IPMI::PP", "use Net::IPMI::PP works"); }
is $warnings, undef, "No warnings";
