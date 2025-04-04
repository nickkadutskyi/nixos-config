{ pkgs, ... }:
pkgs.writeShellScriptBin "aws_ec2_instances"
  # bash
  ''
    AWS=${pkgs.awscli2}/bin/aws
    $AWS ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'sort_by(Reservations[].Instances[], &Tags[?Key==`Name`].Value|[0] || `z-unnamed`)
      [].{InstanceID:InstanceId,Type:InstanceType,State:State.Name,PublicIP:PublicIpAddress,
      PrivateIP:PrivateIpAddress,Name:Tags[?Key==`Name`].Value|[0]}' \
    --output table
  ''
