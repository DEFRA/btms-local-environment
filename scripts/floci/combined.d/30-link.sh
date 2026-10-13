#!/usr/bin/env bash

# trade-gateway-publisher -> trade-imports-processor
# The queue comes from 10-btms.sh and the topic from 20-tgp.sh. Raw delivery because the processor
# reads the body as the publisher's event envelope.
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_updates.fifo --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_gateway_publisher_ched_updates_processor.fifo --attributes '{"RawMessageDelivery":"true"}'

# trade-imports-data-api -> trade-imports-quantity-mgmt
# The topic comes from 10-btms.sh. The service releases CHED reservations when a declaration is finalised.
awslocal sqs create-queue --queue-name trade_imports_data_upserted_quantity_mgmt-deadletter
awslocal sqs create-queue --queue-name trade_imports_data_upserted_quantity_mgmt --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:'"$AWS_REGION"':000000000000:trade_imports_data_upserted_quantity_mgmt-deadletter\",\"maxReceiveCount\":\"1\"}"}'
awslocal sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:trade_imports_data_upserted --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:trade_imports_data_upserted_quantity_mgmt --attributes '{"RawMessageDelivery":"true","FilterPolicy":"{\"ResourceType\":[\"CustomsDeclaration\"],\"SubResourceType\":[\"Finalisation\"]}"}'
