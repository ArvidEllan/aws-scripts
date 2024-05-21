Query to identify failed API authentication attempts:
    source="cloudtrail" eventSource="iam.amazonaws.com" eventName="ConsoleLogin" responseElements.ConsoleLogin="Failure"
    | stats count by userIdentity.userName
    | sort -count
Query to identify potential security policy changes:
    source="cloudtrail" eventName="PutSecurityGroupPolicy" OR eventName="PutBucketPolicy"
    | stats count by userIdentity.userName, eventName
Query to identify privilege escalation attempts:
    source="cloudtrail" eventName="CreateUser" OR eventName="AttachUserPolicy" OR eventName="AttachGroupPolicy" OR eventName="PutUserPolicy"
    | stats count by userIdentity.userName
    | where count > 1
Query to identify failed AWS resource deletion attempts:
    source="cloudtrail" eventName="Delete*"
    | stats count by eventName, userIdentity.userName
    | where eventName="DeleteUser" OR eventName="DeleteGroup" OR eventName="DeletePolicy" OR eventName="DeleteRole" OR eventName="DeleteBucket"
Query to identify successful API calls from new or unknown IP addresses:
    source="cloudtrail" eventName="ConsoleLogin" NOT sourceIPAddress IN (previousIPList)
    | stats count by userIdentity.userName, sourceIPAddress
    | where count = 1
Query to identify unusual IAM role activity:
    source="cloudtrail" eventName="CreateRole" OR eventName="DeleteRole" OR eventName="UpdateAssumeRolePolicy" OR eventName="PutRolePolicy"
    | stats count by userIdentity.userName, eventName
Query to identify potential data exfiltration attempts:
    source="cloudtrail" eventName="PutObject" NOT requestParameters.tagging IS NULL
    | stats count by userIdentity.userName, eventSource, eventName
Query to identify AWS resource modifications by non-administrative users:
    source="cloudtrail" eventName="Modify*"
    | stats count by userIdentity.userName, eventName
    | where eventName!="ModifyInstance" AND eventName!="ModifyVolume" AND eventName!="ModifyVpc"



