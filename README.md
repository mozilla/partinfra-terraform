# Participation Infrastructure
## Terraform resources
### Introduction

``partinfra-terraform`` is a collection of resources and modules to manage the cloud infrastructure that power various sites related to mozilla community.
The code in this repository is authored and maintained by Mozilla engineers and a vibrant community of volunteer contributors.

For more information:

* [Community Ops overview](https://wiki.mozilla.org/Community_Ops)
* [Community Ops PaaS architecture](https://wiki.mozilla.org/Community_Ops/paas)
* [Terraform documentation](https://www.terraform.io/docs/index.html)
* Communication:
  *  IRC: ``#communityit`` on irc.mozilla.org
  *  Discourse: ``https://discourse.mozilla-community.org/c/community-ops``

Get Involved!

### Resources

* ``mesos-cluster``
  * Module that defines the infrastructure required for the community PaaS cluster.
     * [AWS ELB](https://aws.amazon.com/elasticloadbalancing/) load balancer for regional community sites and ``*.mozilla.community`` apps
     * [AWS EC2](https://aws.amazon.com/ec2/) configuration for ``mesos-master`` and ``mesos-slave`` nodes
     * [AWS Autoscaling groups](https://aws.amazon.com/autoscaling/) for ``mesos-master`` and ``mesos-slave`` nodes
     * Security group rules for the ``mesos-cluster`` network flow
  * This acts as the base for our 2 mesos cluster tiers: ``production`` and ``staging``
* ``admin``
  * Deploy [AWS EC2](https://aws.amazon.com/ec2/) instance, security group rules, [AWS ELB](https://aws.amazon.com/elasticloadbalancing/) and SSL termination for admin node.
* ``consul``
  * Deploy shared [AWS VPC](https://aws.amazon.com/vpc/), security group rules and [autoscaling group](https://aws.amazon.com/autoscaling/) for our [consul](https://www.consul.io/) cluster
* ``db``
  * Deploy shared [AWS RDS](https://aws.amazon.com/rds/) (MySQL) instance, security group rules and [AWS Route53](https://aws.amazon.com/route53/) DNS entry for our generic MySQL instance.
* ``network``
  * Deploy staging, production and shared [AWS VPC](https://aws.amazon.com/vpc/) and configure the network flow required for the cluster needs.
* ``terraform``
  * Automation that stores [terraform state](https://www.terraform.io/docs/state/) in [AWS S3](https://aws.amazon.com/s3/).
* ``vpn``
  * Deploy [AWS EC2](https://aws.amazon.com/ec2/) instance and security group rules required for our VPN server.

### Issues

For issue tracking we use bugzilla.mozilla.org. [Create a bug][1] on bugzilla.mozilla.org under ``Participation Infrastructure > Community Ops`` component.

[1]: https://bugzilla.mozilla.org/enter_bug.cgi?product=Participation%20Infrastructure&component=Community%20Ops
