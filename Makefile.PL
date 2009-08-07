use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'CiviCRM::Client::REST',
    AUTHOR              => 'Wes Morgan <wmorgan@cpan.org>',
    LICENSE             => 'perl',
    VERSION_FROM        => 'lib/CiviCRM/Client/REST.pm',
    ABSTRACT_FROM       => 'lib/CiviCRM/Client/REST.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'        => 0,
        'LWP::UserAgent'    => 0,
        'Carp'              => 0,
        'JSON'              => 0,
        'URI::Escape'       => 0,
    },
    MIN_PERL_VERSION    => '5.6.0',
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'CiviCRM-*' },
);
