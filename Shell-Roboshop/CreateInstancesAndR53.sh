#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-032ba9da30e4b33fa"

Route(){
    RECORD_NAME=$1
    IPP=$2
    if [ $RECORD_NAME -eq "frontend" ]; then
        Routing=$(aws route53 change-resource-record-sets \
        --hosted-zone-id Z0971643FE7HKS61G2W9 \
        --change-batch '{
            "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "vijayaws.fun",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [{"Value": "${IPP}"}]
            }
            }]
        }')
    else
        Routing=$(aws route53 change-resource-record-sets \
        --hosted-zone-id Z0971643FE7HKS61G2W9 \
        --change-batch '{
            "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "${RECORD_NAME}.vijayaws.fun",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [{"Value": "${IPP}"}]
            }
            }]
        }')
    fi
}

for Instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --security-group-ids $SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$Instance}]
  --query 'Instances[0].InstanceId'
  --output text)

    if [ $Instance -ne "frontend" ]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID\
        --query "Reservations[0].Instances[0].PrivateIpAddress" \
        --output text)
        Route $Instance $IP
    else
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID\
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text)
        Route $Instance $IP
    fi

    echo "$Instance : $INSTANCE_ID : $IP"
done

