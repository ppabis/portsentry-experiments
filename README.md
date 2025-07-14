Portsentry experiments on AWS
================

This Terraform infra will create a new VPC with at least two EC2 instances with
public IPs. One instance will have Docker and Portsentry installed, while the
other Telnet, FTP clients and Nmap.

Read more on my blog here:

- [https://pabis.eu/blog/2025-07-16-Protect-Instance-With-Portsentry.html](https://pabis.eu/blog/2025-07-16-Protect-Instance-With-Portsentry.html)

The first instance is Blue Team - configure it to be protected from the second
instance - Red Team - who will try to gather information and do recoinassance.

By default I open port 22 and configure SSH, so create `terraform.tfvars` and
give your subnet in the following way:

```hcl
my_ip_cidr = "9.10.11.0/24"
```

It's also possible to change `key_path`, where your PUBLIC SSH key resides and
`red_team_count` if you want to spawn more or less than two instances of the Red
Team (for example to regain access by the attacking and blocked instance).