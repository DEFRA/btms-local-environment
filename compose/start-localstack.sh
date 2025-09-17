#!/bin/bash

if ! command -v jq &> /dev/null; then
    echo "jq is not installed, installing..."
    apt-get update
    apt-get install -y jq
else
    echo "jq is already installed."
fi

export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_REGION=eu-west-2
export AWS_DEFAULT_REGION=eu-west-2
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# data api
aws --endpoint-url=http://localhost:4566 sns create-topic \
    --name trade_imports_data_upserted

# gateway
aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name trade_imports_data_upserted_btms_gateway

aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_btms_gateway \
    --attributes '{"RawMessageDelivery": "true"}'

aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name trade_imports_data_upserted_btms_gateway-deadletter

aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes \
    --queue-url http://localhost:4566/000000000000/trade_imports_data_upserted_btms_gateway \
    --attributes '{"RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_btms_gateway-deadletter\",\"maxReceiveCount\":\"1\"}"}'

SUBSCRIPTION_ARN=$(aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    | jq -r '.Subscriptions[] | select(.Endpoint == "arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_btms_gateway") | .SubscriptionArn')

aws --endpoint-url=http://localhost:4566 sns set-subscription-attributes \
    --subscription-arn $SUBSCRIPTION_ARN \
    --attribute-name FilterPolicy \
    --attribute-value '{"$or": [{"ResourceType": ["CustomsDeclaration"], "SubResourceType": ["ClearanceDecision"]}, {"ResourceType": ["ProcessingError"]}]}'

aws --endpoint-url=http://localhost:4566 sns create-topic \
    --attributes FifoTopic=true \
    --name trade_imports_inbound_customs_declarations.fifo

# processor
aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name trade_imports_inbound_customs_declarations_processor.fifo \
    --attributes FifoQueue=true

aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_inbound_customs_declarations.fifo \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:eu-west-2:000000000000:trade_imports_inbound_customs_declarations_processor.fifo \
    --attributes '{"RawMessageDelivery": "true"}'
    
aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name trade_imports_data_upserted_processor
    
aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_processor \
    --attributes '{"RawMessageDelivery": "true"}'

# decision-deriver
aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name trade_imports_data_upserted_decision_deriver

aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_decision_deriver \
    --attributes '{"RawMessageDelivery": "true"}'

SUBSCRIPTION_ARN=$(aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    | jq -r '.Subscriptions[] | select(.Endpoint == "arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_decision_deriver") | .SubscriptionArn')

aws --endpoint-url=http://localhost:4566 sns set-subscription-attributes \
    --subscription-arn $SUBSCRIPTION_ARN \
    --attribute-name FilterPolicy \
    --attribute-value '{"$or": [{"ResourceType": ["CustomsDeclaration"], "SubResourceType": ["ClearanceRequest"]}, {"ResourceType": ["ImportPreNotification"]}]}'

# decision-comparer
aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name trade_imports_data_upserted_decision_comparer

aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_decision_comparer \
    --attributes '{"RawMessageDelivery": "true"}'

SUBSCRIPTION_ARN=$(aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    | jq -r '.Subscriptions[] | select(.Endpoint == "arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_decision_comparer") | .SubscriptionArn')

aws --endpoint-url=http://localhost:4566 sns set-subscription-attributes \
    --subscription-arn $SUBSCRIPTION_ARN \
    --attribute-name FilterPolicy \
    --attribute-value '{"ResourceType": ["CustomsDeclaration"], "SubResourceType": ["Finalisation"]}'

# reporting api
aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name trade_imports_data_upserted_reporting_api

aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_reporting_api \
    --attributes '{"RawMessageDelivery": "true"}'

SUBSCRIPTION_ARN=$(aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:trade_imports_data_upserted \
    | jq -r '.Subscriptions[] | select(.Endpoint == "arn:aws:sqs:eu-west-2:000000000000:trade_imports_data_upserted_reporting_api") | .SubscriptionArn')

function is_ready() {
    # data api
    aws --endpoint-url=http://localhost:4566 sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_data_upserted')].TopicArn" || return 1
    # gateway
    aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name trade_imports_data_upserted_btms_gateway || return 1
    aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name trade_imports_data_upserted_btms_gateway-deadletter || return 1    
    # processor
    aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name trade_imports_inbound_customs_declarations_processor.fifo || return 1
    aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name trade_imports_data_upserted_processor || return 1
    # decision-deriver
    aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name trade_imports_data_upserted_decision_deriver || return 1
    # decision-comparer
    aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name trade_imports_data_upserted_decision_comparer || return 1
    # reporting api
    aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name trade_imports_data_upserted_reporting_api || return 1
    return 0
}

while ! is_ready; do
    echo "Waiting until ready"
    sleep 1
done

touch /tmp/ready
