package Net::IPMI::PP::Packet::IPMI::Request;
use parent 'Net::IPMI::PP::Packet::IPMI::Message';

my @fields = (
  { format => 'C', name => 'source_addr' },
  { format => 'C', name => {
    'sequence'   => { mask => 0b00000011, shift => 0 },
    'source_lun' => { mask => 0b11111100, shift => 2 },
    }},
  { format => 'C', name => 'command' },
);
sub fields { return \@fields; }

1;
