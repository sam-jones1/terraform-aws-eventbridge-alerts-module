variable "sns_topic_name" {
  type        = string
  description = "The name of the SNS topic to send the alert to"
  default     = null
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the SNS topic to send the alert to if it already exists"
  default     = null
}

variable "sqs_queue_name" {
  type        = string
  description = "The name of the SQS queue to use as the dead letter queue"
  default     = null
}

variable "sqs_queue_arn" {
  type        = string
  description = "The arn of the SQS queue to use as the dead letter queue if it already exists"
  default     = null
}

variable "kms_alerts_flag" {
  type        = bool
  description = "Whether to deploy KMS alerts or not"
  default     = false
}

variable "login_alerts_flag" {
  type        = bool
  description = "Whether to deploy login alerts or not"
  default     = false
}

variable "networking_alerts_flag" {
  type        = bool
  description = "Whether to deploy networking alerts or not"
  default     = false
}

variable "authorization_alerts_flag" {
  type        = bool
  description = "Whether to deploy authorization alerts or not"
  default     = false
}

variable "service_alerts_flag" {
  type        = bool
  description = "Whether to deploy service alerts or not"
  default     = false
}

variable "ec2_alerts_flag" {
  type        = bool
  description = "Whether to deploy EC2 alerts or not"
  default     = false
}

variable "iam_alerts_flag" {
  type        = bool
  description = "Whether to deploy IAM alerts or not"
  default     = false
}

variable "s3_alerts_flag" {
  type        = bool
  description = "Whether to deploy S3 alerts or not"
  default     = false
}

variable "rate_alerts_flag" {
  type        = bool
  description = "Whether to deploy rate alerts or not"
  default     = false
}

locals {
  sns_topic_name = var.sns_topic_name == null ? "cloudtrail-alerts-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}" : var.sns_topic_name
  sqs_queue_name = var.sqs_queue_name == null ? "cloudtrail-alerts-dlq-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}" : var.sqs_queue_name
  kms_alerts = var.kms_alerts_flag == false ? null : {
    kms_key_disabled = jsonencode({"source": ["aws.kms"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["kms.amazonaws.com"],"eventName": ["DisableKey"]}}),
    kms_key_changed = jsonencode({"source": ["aws.kms"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["kms.amazonaws.com"],"eventName": ["CreateKey", "GetKeyPolicy", "PutKeyPolicy", "ImportKeyMaterial"]}}),
    kms_key_deleted = jsonencode({"source": ["aws.kms"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["kms.amazonaws.com"],"eventName": ["ScheduleKeyDeletion"]}})
  }
  login_alerts = var.login_alerts_flag == false ? null : {
    iam_breakglass_login = jsonencode({"source": ["aws.signin"],"detail-type": ["AWS Console Sign In via CloudTrail"],"detail": {"userIdentity": {"userName": ["breakglass"]}}}),
    iam_authentication_failure = jsonencode({"source": ["aws.signin"],"detail-type": ["AWS Console Sign In via CloudTrail"],"detail": {"eventName": ["ConsoleLogin"]}, "errorMessage": ["Failed authentication"]}),
    iam_no_mfa = jsonencode({"source": ["aws.signin"],"detail-type": ["AWS Console Sign In via CloudTrail"],"detail": {"eventName": ["ConsoleLogin"]}, "additionalEventData": {"MFAUsed": ["No"]}})
  }
  networking_alerts = var.networking_alerts_flag == false ? null : {
    security_group_changed = jsonencode({"source": ["aws.ec2"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ec2.amazonaws.com"],"eventName": ["AuthorizeSecurityGroupIngress", "AuthorizeSecurityGroupEgress", "RevokeSecurityGroupIngress", "RevokeSecurityGroupEgress", "CreateSecurityGroup", "DeleteSecurityGroup"]}}),
    nacl_changed = jsonencode({"source": ["aws.ec2"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ec2.amazonaws.com"],"eventName": ["CreateNetworkAcl", "CreateNetworkAclEntry", "DeleteNetworkAcl", "DeleteNetworkAclEntry", "ReplaceNetworkAclEntry", "ReplaceNetworkAclAssociation"]}}),
    gateway_changed = jsonencode({"source": ["aws.ec2"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ec2.amazonaws.com"],"eventName": ["CreateCustomerGateway", "DeleteCustomerGateway", "AttachInternetGateway", "CreateInternetGateway", "DeleteInternetGateway", "DetachInternetGateway"]}}),
    route_table_changed = jsonencode({"source": ["aws.ec2"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ec2.amazonaws.com"],"eventName": ["CreateRoute", "CreateRouteTable", "ReplaceRoute", "ReplaceRouteTableAssociation", "DeleteRouteTable", "DeleteRoute", "DisassociateRouteTable"]}}),
    vpc_changed = jsonencode({"source": ["aws.ec2"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ec2.amazonaws.com"],"eventName": ["DeleteVpc", "CreateVpc", "ModifyVpcAttribute", "AcceptVpcPeeringConnection", "CreateVpcPeeringConnection", "DeleteVpcPeeringConnection", "RejectVpcPeeringConnection", "AttachClassicLinkVpc", "DetachClassicLinkVpc", "DisableVpcClassicLink", "EnableVpcClassicLink"]}})
  }
  authorization_alerts = var.authorization_alerts_flag == false ? null : {
    access_denied = jsonencode({"detail-type": ["AWS API Call via CloudTrail"],"detail": {"errorCode": ["UnauthorizedOperation", "AccessDenied"]}})
  }
  service_alerts = var.service_alerts_flag == false ? null : {
    config_change = jsonencode({"source": ["aws.config"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["config.amazonaws.com"],"eventName": ["StopConfigurationRecorder", "DeleteDeliveryChannel", "PutDeliveryChannel", "PutConfigurationRecorder"]}}),
    cloudtrail_change = jsonencode({"source": ["aws.cloudtrail"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["cloudtrail.amazonaws.com"],"eventName": ["CreateTrail", "UpdateTrail", "DeleteTrail", "StartLogging", "StopLogging"]}})
  }
  ec2_alerts = var.ec2_alerts_flag == false ? null : {
    ec2_status_change = jsonencode({"source": ["aws.ec2"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ec2.amazonaws.com"],"eventName": ["RunInstances", "RebootInstances", "StartInstances", "StopInstances", "TerminateInstances"]}}),
    ec2_large_instance = jsonencode({"source": ["aws.ec2"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ec2.amazonaws.com"],"eventName": ["RunInstances"], "requestParameters": {"instanceType": ["*.8xlarge", "*.4xlarge", "*.16xlarge", "*.10xlarge", "*.12xlarge", "*.24xlarge"]}}})
  }
  iam_alerts = var.iam_alerts_flag == false ? null : {
    iam_policy_changes = jsonencode({"source": ["aws.iam"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["iam.amazonaws.com"],"eventName": ["DeleteGroupPolicy", "DeleteRolePolicy", "DeleteUserPolicy", "PutGroupPolicy", "PutRolePolicy", "PutUserPolicy", "CreatePolicy", "DeletePolicy", "CreatePolicyVersion", "DeletePolicyVersion", "AttachRolePolicy", "DetachRolePolicy", "AttachUserPolicy", "DetachUserPolicy", "AttachGroupPolicy", "DetachGroupPolicy"]}}),
    root_account_usage = jsonencode({"source": ["aws.iam"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"userIdentity": {"type": ["root"], "invokedBy": [""]}, "eventType": [ { "anything-but": "AwsServiceEvent" } ]}})
  }
  s3_alerts = var.s3_alerts_flag == false ? null : {
    s3_changes = jsonencode({"source": ["aws.s3"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["s3.amazonaws.com"],"eventName": ["PutBucketAcl", "PutBucketPolicy", "PutBucketCors", "PutBucketLifecycle", "PutBucketReplication", "DeleteBucketPolicy", "DeleteBucketCors", "DeleteBucketLifecycle", "DeleteBucketReplication"]}})
  }
  rate_alerts = var.rate_alerts_flag == false ? null : {
    ssm_rate_alerts = jsonencode({"source": ["aws.ssm"],"detail-type": ["AWS API Call via CloudTrail"],"detail": {"eventSource": ["ssm.amazonaws.com"],"eventName": ["GetParametersByPath"], "errorCode": ["ThrottlingException"]}})
  }
  all_alerts = merge(local.kms_alerts, local.login_alerts, local.networking_alerts, local.authorization_alerts, local.service_alerts, local.ec2_alerts, local.iam_alerts, local.s3_alerts, local.rate_alerts)
}




