#!/usr/bin/env bash

function is_ready() {
  # trade-imports-data-api
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_data_upserted')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_tracesched_upserted')].TopicArn" || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_tracesched_upserted_queue-deadletter || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_tracesched_upserted_queue || return 1

  # btms-gateway
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_btms_activity')].TopicArn" || return 1
  awslocal sns list-topics --query "Topics[?ends_with(TopicArn, ':trade_imports_inbound_customs_declarations.fifo')].TopicArn" || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_btms_gateway-deadletter || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_btms_gateway || return 1

  # trade-imports-decision-deriver
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_decision_deriver-deadletter || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_decision_deriver || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_tracesched_upserted_decision_deriver-deadletter || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_tracesched_upserted_decision_deriver || return 1

  # trade-imports-processor
  awslocal sqs get-queue-url --queue-name trade_imports_inbound_customs_declarations_processor-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_inbound_customs_declarations_processor.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_processor-deadletter || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_processor || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_updates_processor.fifo || return 1

  # trade-imports-reporting-api
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_reporting_api-deadletter || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_reporting_api || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_btms_activity_reporting_api-deadletter || return 1
  awslocal sqs get-queue-url --queue-name trade_imports_btms_activity_reporting_api || return 1

  # GMR Finder -> BTMS GVMS queue
  awslocal sqs get-queue-url --queue-name trade_imports_matched_gmrs_btms_processor || return 1

  return 0
}

is_ready
