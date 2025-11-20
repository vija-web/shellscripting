#!/bin/bash

for Instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
  --image-id ami-09c813fb71547fc4f \
  --instance-type t3.micro \
  --security-group-ids sg-032ba9da30e4b33fa \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$Instance}]
  --query 'Instances[0].InstanceId'
  --output text)

    if [ $Instance -ne "frontend"]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID\
        --query "Reservations[0].Instances[0].PrivateIpAddress" \
        --output text)
    else
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID\
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text)
    fi
    echo "$Instance : $INSTANCE_ID : $IP"
done

