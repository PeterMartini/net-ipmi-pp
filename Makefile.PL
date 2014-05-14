use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Net::IPMI::PP',
    VERSION_FROM => 'lib/Net/IPMI/PP.pm',
    test         => { TESTS => 't/*/*.t'},
);
