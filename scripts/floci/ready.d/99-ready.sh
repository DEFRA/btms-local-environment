#!/bin/bash

function is_ready() {
  # trade-imports-data-api
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_data_upserted')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_tracesched_upserted')].TopicArn" || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_tracesched_upserted_queue-deadletter || 1
  awslocal sqs get-queue-url --queue-name trade_imports_tracesched_upserted_queue || 1

  # btms-gateway
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_btms_activity')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_inbound_customs_declarations.fifo')].TopicArn" || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_btms_gateway-deadletter || 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_btms_gateway || 1

  # trade-imports-decision-deriver
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_decision_deriver-deadletter || 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_decision_deriver || 1

  # trade-imports-processor
  awslocal sqs get-queue-url --queue-name trade_imports_inbound_customs_declarations_processor-deadletter.fifo || 1
  awslocal sqs get-queue-url --queue-name trade_imports_inbound_customs_declarations_processor.fifo || 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_processor-deadletter || 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_processor || 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_updates_processor.fifo || 1

  # trade-imports-reporting-api
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_reporting_api-deadletter || 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_reporting_api || 1
  awslocal sqs get-queue-url --queue-name trade_imports_btms_activity_reporting_api-deadletter || 1
  awslocal sqs get-queue-url --queue-name trade_imports_btms_activity_reporting_api || 1

  # GMR Finder -> BTMS GVMS queue
  awslocal sqs get-queue-url --queue-name trade_imports_matched_gmrs_btms_processor || 1

  return 0
}

while ! is_ready; do
  echo "Waiting until ready..."
  sleep 1
done
