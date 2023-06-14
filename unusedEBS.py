import json
from os import getenv, environ
import boto3
from datetime import datetime

region = environ['AWS_REGION']
sns_topic_arn = "arn:aws:sns:eu-west-1:930106324387:aws-space-delete"

#define the connection
ec2 = boto3.resource('ec2', region_name=region)
sns = boto3.client('sns', region_name=region)

#set the date to today
today = datetime.now().date()

def get_volumes():
    # Report headers
    ebs_report = "The Following EBS Volumes are Unused:\n"
    ami_report = "The Following AMIs are Unused:\n"
    snapshot_report = "The Following Snapshots are Unused:\n"
    number_ebs = 0
    number_ami = 0
    number_snapshot = 0

    # Collect all AWS EBS volumes, AMIs, and snapshots in a region
    volumes = ec2.volumes.all()
    amis = ec2.images.filter(Owners=['self'])
    snapshots = ec2.snapshots.filter(OwnerIds=['self'])

    # Check for unused EBS volumes
    for vol in volumes:
        if vol.state == "available":
            ebs_report += f"- {vol.id} - Size: {vol.size} - Created: {vol.create_time.strftime('%Y/%m/%d %H:%M')}\n"
            number_ebs += 1

    # Check for unused AMIs
    for ami in amis:
        launch_time = ami.creation_date
        if launch_time:
            launch_datetime = datetime.strptime(launch_time, '%Y-%m-%dT%H:%M:%S.%fZ')
            if (datetime.now() - launch_datetime).days > 90:
                ami_report += f"- {ami.id} - Name: {ami.name} - Created: {launch_datetime.strftime('%Y/%m/%d %H:%M')}\n"
                number_ami += 1

    # Check for unused snapshots
    for snapshot in snapshots:
        if not ec2.images.filter(Owners=['self'], Filters=[{'Name': 'block-device-mapping.snapshot-id', 'Values': [snapshot.id]}]).all():
            snapshot_report += f"- {snapshot.id} - Created: {snapshot.start_time.strftime('%Y/%m/%d %H:%M')}\n"
            number_snapshot += 1

    # Send a report if there are unused resources
    if number_ebs == 0 and number_ami == 0 and number_snapshot == 0:
        print("Nothing to Report")
    else:
        full_report = ebs_report + "\n" + ami_report + "\n" + snapshot_report
        response = sns.publish(
            TargetArn=sns_topic_arn,
            Message=full_report,
            Subject='Unused EBS Volumes, AMIs, and Snapshots Report: ' + str(today),
            MessageStructure='string'
        )

def lambda_handler(event, context):
    # TODO implement
    get_volumes()
    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }
