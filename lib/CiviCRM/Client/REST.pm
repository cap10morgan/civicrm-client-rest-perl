package CiviCRM::Client::REST;

require 5.6.0;
use strict;
use vars qw($VERSION);
use Carp;
use LWP::UserAgent;
use JSON;
use URI::Escape;

$VERSION = "0.01";
my $debug = 0;

=head1 NAME

CiviCRM::Client::REST - Client library for the CiviCRM REST API

This Perl module provides a wrapper around the REST web services
exposed by CiviCRM. It makes interacting with CiviCRM from Perl
scripts much simpler.

=head1 SYNOPSIS

use CiviCRM::Client;

my $civicrm = CiviCRM::Client::REST->new('http://mysite.org/civicrm_root/', 'my_civicrm_site_key');
$civicrm->login(name => 'username', pass => 'password');
my $contacts = $civicrm->contact_search(email => 'me@here.com');

=head1 DESCRIPTION

The CiviCRM Perl module is a wrapper around LWP::Useragent that makes
calling the CiviCRM REST web services much easier from a Perl script.

It uses AUTOLOAD to dynamically construct the URI of the web service
based on the method name you use. This is easiest to understand by
example:

$civicrm->contact_add($params);

results in:

http://mysite.org/civicrm_root/index.php?q=civicrm/contact/add&foo=bar...

This module is not aware of the web services that exist, it merely
calls them based on the methods you call on it. This is a Good Thing
because you can add your own API methods to your local CiviCRM
instance and then call them with this module. It will also continue
to work with future releases of CiviCRM as long as it keeps
following the API method naming convention that is being introduced
and will hopefully be complete in version 3.1 (not released as of this writing, but many methods will work in versions 2.2 and 3.0 also; give it a try).

=head2 Available Methods

In theory this module should work with all methods that the current 
or future releases of CiviCRM expose. It does this via the AUTOLOAD
functionality of Perl, which lets you handle subs you don't
explicitly define (it's very cool).

For the current list of available API methods, see this page:
http://wiki.civicrm.org/confluence/display/CRMDOC/CiviCRM+Public+APIs

In general, any API method can be called on this module by dropping
the "civicrm_" prefix and calling it on an instance of this module.
This is mostly true for CiviCRM 2.2+ (it's unknown prior to that), but
will hopefully be fully true for 3.1 and the foreseeable future after that.
So, for civicrm_activity_type_create, you would do something like 
this:

my $civicrm = CiviCRM->new($site_params);
$civicrm->login($credentials);
$civicrm->activity_type_create($activity_type);

=head1 AUTHOR

This module was written by Wes Morgan <wmorgan@cpan.org>.

=over

=item new()

Counstructor method. Requires that you pass the root URL of your CiviCRM server
and the site key for that server.

Use it like this:

my $civicrm = CiviCRM->new($root_url, $site_key);

=cut

sub new {
    my ($class, $civicrmUrl, $siteKey) = @_;
    my $self = {};
    $self->{_ua}             = LWP::UserAgent->new();
    $self->{_civicrmUrl}     = $civicrmUrl;
    $self->{_siteKey}        = $siteKey;
    $self->{_sessionKeyName} = 'key';
    bless($self, $class);
    return $self;
}

=item getSiteKey()

Private sub; just used by the module. Feel free to ignore.

=cut

sub getSiteKey {
    my ($self) = @_;
    return $self->{_siteKey};
}

=item setSessionKey()

Private sub; just used by the module. Feel free to ignore.

=cut

sub setSessionKey {
    my ($self, $key, $keyName) = @_;
    $self->{_sessionKey} = $key;
    $self->{_sessionKeyName} = $keyName;
}

=item getSessionKey()

Private sub; just used by the module. Feel free to ignore.

=cut

sub getSessionKey {
    my ($self) = @_;
    return $self->{_sessionKey};
}

=item getSessionKeyName()

Private sub; just used by the module. Feel free to ignore.

=cut

sub getSessionKeyName {
    my ($self) = @_;
    return $self->{_sessionKeyName};
}

=item ua()

Private sub; just used by the module. Feel free to ignore.

=cut

sub ua {
    my ($self) = @_;
    return $self->{_ua};
}

=item AUTOLOAD()

This is where the magic happens. You needn't worry about how it works.
If you're just curious, read up on Perl's AUTOLOAD functionality. This is a
fairly basic use of it.

=cut

sub AUTOLOAD {
    our $AUTOLOAD;
    return if $AUTOLOAD =~ /::DESTROY$/;
    my $self = shift;
    my $args = shift;
    $AUTOLOAD =~ /::([^:]+)$/;
    my $method = $1;
    my @methodComponents = split('_', $method);
    my $methodComCount = scalar( @methodComponents );
    my $methodUrl =
        join( '_', splice( @methodComponents, 0, $methodComCount-1 ) );
    $methodUrl .= '/' if ($methodUrl ne '' && $methodUrl !~ /\/$/);
    $methodUrl .= pop( @methodComponents );
    print "Method URL: $methodUrl\n" if $debug > 0;
    my @argsArr;
    foreach my $name (keys(%{$args})) {
        my $arg = URI::Escape::uri_escape_utf8($name)."=";
        $arg   .= URI::Escape::uri_escape_utf8($args->{$name});
        push(@argsArr, $arg);
    }
    my $argsUrl = join('&', @argsArr);
    my $key = $self->getSiteKey();
    my $url = $self->{_civicrmUrl} . "/extern/rest.php?q=civicrm/$methodUrl&$argsUrl";
    $url .= "&" if $url !~ /&$/;
    $url .= "json=1&key=$key";
    if ($method ne 'login') {
        $url .= "&" . $self->getSessionKeyName() . "=" . $self->getSessionKey();
    }
    print "Trying URL: $url\n" if $debug > 0;
    my $response = $self->ua->get($url);
    if ($response->is_success) {
        my $content = $response->content;
        print "Response: $content\n" if $debug > 0;
        my $returnObj = from_json($content);
        if ($returnObj->{is_error}) {
            carp "ERROR: ".$returnObj->{error_message}."\n" if $debug > 0;
        } elsif ($method eq 'login') {
            if ( $returnObj->{PHPSESSID} ) {
                $self->setSessionKey($returnObj->{PHPSESSID},'PHPSESSID');
            }
        }
        return $returnObj;
    } else {
        carp "Response error: ".$response->content if $debug > 0;
        return undef;
    }
}

1;
