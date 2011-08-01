#!/usr/bin/perl -w

use strict;
use warnings;

use Atomia::Bindings::CoreAPI;
use Data::Dumper;

die "usage: $0 adminpass" unless scalar(@ARGV) > 0;

my $coreapi = Atomia::Bindings::CoreAPI->new(endpoint => "https://provisioning.int.atomia.com/CoreAPIBasicAuth.svc", username => "Administrator", password => $ARGV[0], trace => 0);

eval {
	my $services = $coreapi->FindServicesByPath(
		Atomia::Bindings::CoreAPI::ServiceSearchCriteriaArray->new(criterias => [ {
			parent_service => undef,
			service_name => "CsLinuxInstance",
			service_path => "CsCloud/CsInstances",
		} ]),
		Atomia::Bindings::CoreAPI::Account->new(name => 100052));

	if (defined($services) && ref($services) eq "HASH") {
		$services = $services->{"ProvisioningService"};
		$services = [ $services ] if defined($services) && ref($services) ne 'ARRAY';

		if (defined($services)) {
			print scalar(@$services) . " services found, trying to delete the first\n";
			$coreapi->DeleteService(Atomia::Bindings::CoreAPI::ProvisioningService->new(fetched => $services->[0]), Atomia::Bindings::CoreAPI::Account->new(element_name => "accountName", name => 100052));
		}
	}

	$services = $coreapi->FindServicesByPath(
		Atomia::Bindings::CoreAPI::ServiceSearchCriteriaArray->new(criterias => [ {
			parent_service => undef,
			service_name => "CsInstances",
			service_path => "CsCloud",
		} ]),
		Atomia::Bindings::CoreAPI::Account->new(name => 100052));

	my $cs_instances = undef;
	if (defined($services) && ref($services) eq "HASH") {
		$services = $services->{"ProvisioningService"};
		$services = [ $services ] if defined($services) && ref($services) ne 'ARRAY';
		$cs_instances = Atomia::Bindings::CoreAPI::ProvisioningService->new(element_name => "parentService", fetched => $services->[0]) if defined($services) && scalar($services) > 0;
	}

	die "CsInstances not found" unless defined($cs_instances);

	my $new_service = $coreapi->CreateService(Atomia::Bindings::CoreAPI::ServiceName->new(name => "CsLinuxInstance"), $cs_instances, Atomia::Bindings::CoreAPI::Account->new(element_name => "accountName", name => 100052));
	$new_service = Atomia::Bindings::CoreAPI::ProvisioningService->new(fetched => $new_service);
	$new_service->setprop("Name", "autoscaletest_node1");
	$new_service->setprop("InstanceType", "m1.tiny");
	$new_service->setprop("ImageId", "ami-00000002");
	$new_service->setprop("KeyPair", "democluster");
	$new_service->setprop("GlobalSecurityGroup", "webservers");
	$new_service->setprop("AgentPassword", "foo");
	$coreapi->AddService($new_service, $cs_instances, Atomia::Bindings::CoreAPI::Account->new(element_name => "accountName", name => 100052));

	print "New instance provisioned successfully\n";
};

if ($@) {
	print "exception: " . $@->message . "\n";
}
