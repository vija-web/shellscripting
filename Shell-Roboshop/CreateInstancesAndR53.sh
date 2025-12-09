#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-032ba9da30e4b33fa"

Route() {
    RECORD_NAME=$1
    IPP=$2

    if [ "$RECORD_NAME" = "frontend" ]; then
        FQDN="vijayaws.fun"
    else
        FQDN="${RECORD_NAME}.vijayaws.fun"
    fi

    Routing=$(aws route53 change-resource-record-sets \
        --hosted-zone-id Z0971643FE7HKS61G2W9 \
        --change-batch "{
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"${FQDN}\",
                    \"Type\": \"A\",
                    \"TTL\": 1,
                    \"ResourceRecords\": [{\"Value\": \"${IPP}\"}]
                }
            }]
        }")
}

for Instance in "$@"
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$Instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [ "$Instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
    fi

    Route "$Instance" "$IP"
    echo "$Instance : $INSTANCE_ID : $IP"
done
