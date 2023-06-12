##startec2
import boto3
region = 'us-west-1'
instances = ['i-08d7533927d8c728e']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))
    
##stopec2
import boto3
region = 'us-west-1'
instances = ['i-08d7533927d8c728e']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))