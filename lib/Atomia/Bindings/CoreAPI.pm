#!/usr/bin/perl -w

use strict;
use warnings;

package Atomia::Bindings::CoreAPI;

use Moose;
use Atomia::Bindings::CoreAPI::Exception;
use Atomia::Bindings::CoreAPI::Account;
use Atomia::Bindings::CoreAPI::ProvisioningService;
use Atomia::Bindings::CoreAPI::ServiceName;
use Atomia::Bindings::CoreAPI::ServiceSearchCriteriaArray;
use Atomia::Bindings::CoreAPI::StringWithName;

use Scalar::Util qw(blessed);
our $AUTOLOAD;

has 'endpoint' => (is => 'ro', isa => 'Str');
has 'username' => (is => 'ro', isa => 'Str');
has 'password' => (is => 'ro', isa => 'Str');
has 'security' => (is => 'rw', isa => 'Object');
has 'trace' => (is => 'rw', isa => 'Int', default => 0);
has 'configfile' => (is => 'ro', isa => 'Str', default => "/etc/atomia-bindings.conf");
has 'config' => (is => 'rw', isa => 'HashRef');
has 'soap' => (is => 'rw', isa => 'Object');
has 'security' => (is => 'rw', isa => 'Object');

sub AUTOLOAD {
	my $action = $AUTOLOAD;
	my $self = shift;
	return $self->_action_wrapper($action, @_);
}
	
sub BUILD {
        my $self = shift;

	if (defined($self->configfile) && -f $self->configfile) {
	        my $conf = new Config::General($self->configfile);
	        die("invalid config at $self->configfile") unless defined($conf);
	        my %config = $conf->getall;
	        $self->config(\%config);
	} else {
		$self->config({});
	}

	if ($self->trace) {
		eval 'use SOAP::Lite +trace => [ "debug" ];';
	} else {
		eval 'use SOAP::Lite;';
	}

	my $username = $self->username || $self->config->{"username"} || die "you have to pass username in constructor or set it in config file ($self->configfile)";
	my $password = $self->password || $self->config->{"password"} || die "you have to pass password in constructor or set it in config file ($self->configfile)";
	$self->security(
		SOAP::Header->name("wsse:Security")->attr({'soap:mustUnderstand' => 1,'xmlns:wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'})->value(
			\SOAP::Header->name("wsse:UsernameToken", \SOAP::Header->value(
				SOAP::Header->name('wsse:Username')->value($username)->type(''),
				SOAP::Header->name('wsse:Password')->value($password)->type('')->attr({'Type'=>'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'})
			))
		)
	);

	my $endpoint = $self->endpoint || $self->config->{"endpoint"} || die "you have to pass endpoint in constructor or set it in config file ($self->configfile)";
	$self->soap(SOAP::Lite
	        -> xmlschema(2001)
	        -> default_ns('http://atomia.com/atomia/provisioning/')
	        -> on_action(sub { sprintf '"%sICoreApi/%s"', @_ })
	        -> proxy($endpoint)
		->  on_fault(sub {
			my($soapself, $res) = @_;
			die Atomia::Bindings::CoreAPI::Exception->new(message => 
				"got fault of type " . (ref $res ? $res->faultcode  : "transport") . ": " . (ref $res ? $res->faultstring : $soapself->transport->status) . "\n");
		}));
}

sub _action_wrapper {
	my $self = shift;

	my $action_name = shift;
	$action_name =~ s/^.*::([^:]*)$/$1/;

	my $args = $self->_serialize_args(@_);

	my $ret = $self->soap->$action_name($self->security, @$args);
	die Atomia::Bindings::CoreAPI::Exception->new(message => "error calling $action_name action") unless defined($ret);
	return $ret->result;
}

sub _serialize_args {
	my $self = shift;

	my $args = [];
	foreach my $arg (@_) {
		if (defined($arg) && blessed($arg) && $arg->can('serialize')) {
			push @$args, $arg->serialize();
		} else {
			push @$args, $arg;
		}
	}
	return $args;
}

1;
