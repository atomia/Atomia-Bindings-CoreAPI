This is a simple perl binding for connecting to [Atomia Automation Server](http://www.atomia.com) CoreAPI.

It supports all methods, and includes helper classes for easing the SOAP serialization pain of parameters with
one of the following data types:

* ProvisioningService
* ServiceSearchCriteria[]

This will be extended in the future as needed, if you need some other data type, feel free to add and
send merge request.

## Example

```perl
        my $coreapi = Atomia::Bindings::CoreAPI->new(
                endpoint => "https://some.provisioning.host/CoreAPIBasicAuth.svc",
                username => "Administrator", password => "somepass");

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
                $cs_instances = Atomia::Bindings::CoreAPI::ProvisioningService->new(
                        element_name => "parentService",
                        fetched => $services->[0]) if defined($services) && scalar($services) > 0;
        }

        die "CsInstances not found" unless defined($cs_instances);

        my $new_service = $coreapi->CreateService(Atomia::Bindings::CoreAPI::ServiceName->new(
                name => "CsLinuxInstance"),
                $cs_instances,
                Atomia::Bindings::CoreAPI::Account->new(element_name => "accountName", name => 100052));

        $new_service = Atomia::Bindings::CoreAPI::ProvisioningService->new(fetched => $new_service);
        $new_service->setprop("Name", "autoscaletest_node1");
        $new_service->setprop("InstanceType", "m1.tiny");
        $new_service->setprop("ImageId", "ami-00000002");
        $new_service->setprop("KeyPair", "democluster");
        $new_service->setprop("GlobalSecurityGroup", "webservers");
        $new_service->setprop("AgentPassword", "foo");
        $coreapi->AddService($new_service, $cs_instances,
                Atomia::Bindings::CoreAPI::Account->new(element_name => "accountName", name => 100052));

        print "New instance provisioned successfully\n";
```
