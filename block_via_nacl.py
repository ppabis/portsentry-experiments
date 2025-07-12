#!/usr/bin/env python3

import argparse, sys, re, boto3

# Replace this with your actual ACL ID.
NACL_ID = "acl-0123456789abcdef0"


def parse_args():
    parser = argparse.ArgumentParser( description="Add a deny ingress rule for a single IPv4 address to the configured AWS Network ACL." )
    parser.add_argument( "ip", help="IPv4 address to block (e.g., 203.0.113.15)", type=str )
    args = parser.parse_args()
    if not re.match(r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", args.ip):
        print("Invalid IP address", file=sys.stderr)
        sys.exit(1)
    return args


def get_nacl(ec2):
    nacls = ec2.describe_network_acls(NetworkAclIds=[NACL_ID])["NetworkAcls"]
    if not nacls:
        return None
    return nacls[0]


def does_rule_exist(nacl, cidr_block):
    for entry in nacl["Entries"]:
        if (
            entry.get("CidrBlock") == cidr_block
            and entry["RuleAction"].lower() == "deny"
            and entry["Egress"] is False
        ):
            print(f"A deny rule for {cidr_block} already exists at {entry['RuleNumber']}.")
            return True
    return False


def find_space_for_rule(nacl):
    existing_numbers = { entry["RuleNumber"] for entry in nacl["Entries"] if entry["Egress"] is False }
    for candidate in range(5, 99):
        if candidate not in existing_numbers:
            return candidate
    return None


def main():
    args = parse_args()
    cidr_block = f"{args.ip}/32"
    ec2 = boto3.client("ec2")

    acl = get_nacl(ec2)
    if not acl:
        print(f"No Network ACL found with ID {NACL_ID}", file=sys.stderr)
        sys.exit(1)
    
    if does_rule_exist(acl, cidr_block):
        return
    
    rule_number = find_space_for_rule(acl)

    if rule_number is None:
        print("No available rule numbers left in the NACL", file=sys.stderr)
        sys.exit(1)

    ec2.create_network_acl_entry(
            NetworkAclId=NACL_ID,
            RuleNumber=rule_number,
            Protocol="-1",  # -1 means all protocols
            RuleAction="deny",
            Egress=False,  # ingress rule
            CidrBlock=cidr_block,
    )
    
    print(f"Successfully added deny ingress rule {rule_number} for {cidr_block} in ACL {NACL_ID}.")


if __name__ == "__main__":
    main()
