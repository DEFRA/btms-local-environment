#!/usr/bin/env bash

function is_ready() {
  /etc/floci/btms.d/99-ready.sh || return 1

  # trade-gateway-publisher
  awslocal s3 ls s3://reports || return 1
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_stream_internal.fifo" >/dev/null || return 1
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_updates.fifo" >/dev/null || return 1
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_stream_internal.fifo" >/dev/null || return 1
  awslocal sns get-topic-attributes --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_intra_updates.fifo" >/dev/null || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_asb_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_ched_stream_internal_asb_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_asb_publisher-deadletter.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_stream_internal_asb_publisher.fifo || return 1
  awslocal sqs get-queue-url --queue-name trade_gateway_publisher_intra_updates_test.fifo || return 1

  # trade-gateway-publisher -> trade-imports-processor
  awslocal sns list-subscriptions-by-topic --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_gateway_publisher_ched_updates.fifo" | grep -q trade_gateway_publisher_ched_updates_processor.fifo || return 1

  # trade-imports-data-api -> trade-imports-quantity-mgmt
  awslocal sqs get-queue-url --queue-name trade_imports_data_upserted_quantity_mgmt-deadletter || return 1
  awslocal sns list-subscriptions-by-topic --topic-arn "arn:aws:sns:$AWS_REGION:000000000000:trade_imports_data_upserted" | grep -q trade_imports_data_upserted_quantity_mgmt || return 1

  return 0
}

is_ready
