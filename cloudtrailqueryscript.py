import boto3

def cloudtrail_query(query):
    client = boto3.client('logs', region_name='your_region') # Change 'your_region' to your AWS region
    response = client.start_query(
        logGroupName='your_log_group_name', # Change 'your_log_group_name' to your CloudTrail log group name
        startTime=int((datetime.datetime.now() - datetime.timedelta(days=7)).timestamp()), # Adjust the time range as needed
        endTime=int(datetime.datetime.now().timestamp()),
        queryString=query,
        limit=10000
    )
    query_id = response['queryId']
    response = None
    while response == None or response['status'] == 'Running':
        print('Waiting for query to complete...')
        time.sleep(5)
        response = client.get_query_results(
            queryId=query_id
        )
    return response

def main():
    # Queries
    queries = [
        'fields @timestamp, userIdentity.userName | filter eventSource = "iam.amazonaws.com" AND eventName = "ConsoleLogin" AND responseElements.ConsoleLogin = "Failure" | stats count by userIdentity.userName | sort -count',
        'fields @timestamp, userIdentity.userName, eventName | filter eventName = "PutSecurityGroupPolicy" OR eventName = "PutBucketPolicy" | stats count by userIdentity.userName, eventName',
        'fields @timestamp, userIdentity.userName | filter eventName = "CreateUser" OR eventName = "AttachUserPolicy" OR eventName = "AttachGroupPolicy" OR eventName = "PutUserPolicy" | stats count by userIdentity.userName | where count > 1',
        'fields @timestamp, eventName, userIdentity.userName | filter eventName like "Delete%" | stats count by eventName, userIdentity.userName | where eventName = "DeleteUser" OR eventName = "DeleteGroup" OR eventName = "DeletePolicy" OR eventName = "DeleteRole" OR eventName = "DeleteBucket"',
        'fields @timestamp, userIdentity.userName, sourceIPAddress | filter eventName = "ConsoleLogin" AND NOT sourceIPAddress IN (previousIPList) | stats count by userIdentity.userName, sourceIPAddress | where count = 1',
        'fields @timestamp, userIdentity.userName, eventName | filter eventName = "CreateRole" OR eventName = "DeleteRole" OR eventName = "UpdateAssumeRolePolicy" OR eventName = "PutRolePolicy" | stats count by userIdentity.userName, eventName',
        'fields @timestamp, userIdentity.userName, eventSource, eventName | filter eventName = "PutObject" AND NOT requestParameters.tagging IS NULL | stats count by userIdentity.userName, eventSource, eventName',
        'fields @timestamp, userIdentity.userName, eventName | filter eventName like "Modify*" | stats count by userIdentity.userName, eventName | where eventName!="ModifyInstance" AND eventName!="ModifyVolume" AND eventName!="ModifyVpc"',
        'fields @timestamp, eventName | filter NOT eventName like "Describe*" AND NOT eventName like "List*" AND NOT eventName like "Get*" | stats count by eventName',
        'fields @timestamp, userIdentity.userName, eventName | filter eventName = "CreateFunction" OR eventName = "UpdateFunctionConfiguration" OR eventName = "UpdateFunctionCode" OR eventName = "DeleteFunction" | stats count by userIdentity.userName, eventName'
    ]
    
    for query in queries:
        print(f"Executing query: {query}")
        response = cloudtrail_query(query)
        # Process response as needed
        print(response)

if __name__ == "__main__":
    main()





