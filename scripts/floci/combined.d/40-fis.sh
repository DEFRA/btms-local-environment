#!/usr/bin/env bash

# FIS Simulator
# Create the SNS topic and SQS queue, then subscribe the queue to the topic.

# SNS topic
awslocal sns create-topic \
  --name trade_imports_iuunotification_sim_upserted

# SQS queue
awslocal sqs create-queue \
  --queue-name trade_imports_iuunotification_sim_upserted_queue \
  --attributes '{"Policy":"{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"sns.amazonaws.com\"},\"Action\":\"sqs:SendMessage\",\"Resource\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_iuunotification_sim_upserted_queue\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"arn:aws:sns:'"$AWS_REGION"':000000000000:trade_imports_iuunotification_sim_upserted\"}}}]}"}'

# SNS → SQS subscription
awslocal sns subscribe \
  --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_iuunotification_sim_upserted \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_iuunotification_sim_upserted_queue \
  --attributes '{"RawMessageDelivery":"true"}'