#!/usr/bin/env bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_STS AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SECURITY_TOKEN AWS_SESSION_TOKEN
export USERNAME=terraform
export AWS_DEFAULT_REGION=eu-west-1
export AWS_ACCESS_KEY_ID=AKIAX76HZMJWLRCBLKFG
export AWS_SECRET_ACCESS_KEY=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
export ROLE_NAME=EC2TerraformRole
export ACCOUNT_ARN=arn:aws:iam::549637939820
export MFA_CODE=$1
AWS_STS=($(aws sts assume-role --role-arn $ACCOUNT_ARN:role/$ROLE_NAME --serial-number $ACCOUNT_ARN:mfa/$USERNAME --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken,Credentials.Expiration]' --output text --token-code $MFA_CODE --role-session-name $ROLE_NAME))
export AWS_ACCESS_KEY_ID=${AWS_STS[0]}
export AWS_SECRET_ACCESS_KEY=${AWS_STS[1]}
export AWS_SECURITY_TOKEN=${AWS_STS[2]}
export AWS_SESSION_TOKEN=${AWS_STS[2]}
