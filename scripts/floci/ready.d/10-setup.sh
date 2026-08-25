#!/usr/bin/env bash

# trade-imports-data-api
awslocal sns create-topic --name trade_imports_data_upserted
awslocal sns create-topic --name trade_imports_tracesched_upserted
awslocal sqs create-queue --queue-name trade_imports_tracesched_upserted_queue-deadletter
awslocal sqs create-queue --queue-name trade_imports_tracesched_upserted_queue --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_tracesched_upserted_queue-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_tracesched_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_tracesched_upserted_queue --attributes '{"RawMessageDelivery":"true"}'

# btms-gateway
awslocal sns create-topic --name trade_imports_btms_activity
awslocal sns create-topic --name trade_imports_inbound_customs_declarations.fifo --attributes '{"FifoTopic":"true"}'
awslocal sqs create-queue --queue-name trade_imports_data_upserted_btms_gateway-deadletter
awslocal sqs create-queue --queue-name trade_imports_data_upserted_btms_gateway --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_data_upserted_btms_gateway-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_data_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_data_upserted_btms_gateway --attributes '{"RawMessageDelivery":"true","FilterPolicy":"{\"$or\":[{\"ResourceType\":[\"CustomsDeclaration\"],\"SubResourceType\":[\"ClearanceDecision\"]},{\"ResourceType\":[\"ProcessingError\"]}]}"}'

# trade-imports-decision-deriver
awslocal sqs create-queue --queue-name trade_imports_data_upserted_decision_deriver-deadletter
awslocal sqs create-queue --queue-name trade_imports_data_upserted_decision_deriver --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_data_upserted_decision_deriver-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_data_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_data_upserted_decision_deriver --attributes '{"RawMessageDelivery":"true","FilterPolicy":"{\"$or\":[{\"ResourceType\":[\"CustomsDeclaration\"],\"SubResourceType\":[\"ClearanceRequest\"]},{\"ResourceType\":[\"ImportPreNotification\"]}]}"}'
awslocal sqs create-queue --queue-name trade_imports_tracesched_upserted_decision_deriver-deadletter
awslocal sqs create-queue --queue-name trade_imports_tracesched_upserted_decision_deriver --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_tracesched_upserted_decision_deriver-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_tracesched_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_tracesched_upserted_decision_deriver --attributes '{"RawMessageDelivery":"true"}'

# trade-imports-processor
awslocal sqs create-queue --queue-name trade_imports_inbound_customs_declarations_processor-deadletter.fifo --attributes '{"FifoQueue":"true"}'
awslocal sqs create-queue --queue-name trade_imports_inbound_customs_declarations_processor.fifo --attributes '{"FifoQueue":"true","RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_inbound_customs_declarations_processor-deadletter.fifo\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_inbound_customs_declarations.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_inbound_customs_declarations_processor.fifo --attributes '{"RawMessageDelivery":"true"}'
awslocal sqs create-queue --queue-name trade_imports_data_upserted_processor-deadletter
awslocal sqs create-queue --queue-name trade_imports_data_upserted_processor --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_data_upserted_processor-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_data_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_data_upserted_processor --attributes '{"RawMessageDelivery":"true"}'
awslocal sqs create-queue --queue-name trade_gateway_publisher_ched_updates_processor.fifo --attributes '{"FifoQueue":"true"}'

# trade-imports-reporting-api
awslocal sqs create-queue --queue-name trade_imports_data_upserted_reporting_api-deadletter
awslocal sqs create-queue --queue-name trade_imports_data_upserted_reporting_api --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_data_upserted_reporting_api-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_data_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_data_upserted_reporting_api --attributes '{"RawMessageDelivery":"true"}'
awslocal sqs create-queue --queue-name trade_imports_btms_activity_reporting_api-deadletter
awslocal sqs create-queue --queue-name trade_imports_btms_activity_reporting_api --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_btms_activity_reporting_api-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_data_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_data_upserted_decision_deriver --attributes '{"RawMessageDelivery":"true"}'

# GMR Finder -> BTMS GVMS queue
awslocal sqs create-queue --queue-name trade_imports_matched_gmrs_btms_processor
