#!/bin/sh
set -eu

# Registers a portal user in cdp-defra-id-stub. Registrations live in Redis and expire, so this runs on
# every start. A fixed userId makes it idempotent: the stub replaces a registration with the same ID.
#
# relationshipId is set to the organisation ID to work around a stub bug
# (https://github.com/DEFRA/cdp-defra-id-stub/pull/39). The organisation is the one
# config/btms-portal-frontend.env allows by default.

curl --fail-with-body --silent --show-error \
  -X POST http://cdp-defra-id-stub:3200/cdp-defra-id-stub/API/register \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "00000000-0000-0000-0000-000000000100",
    "email": "btms-tester@example.com",
    "firstName": "BTMS",
    "lastName": "Tester",
    "loa": "1",
    "enrolmentCount": 1,
    "enrolmentRequestCount": 1,
    "relationships": [{
      "relationshipId": "00000000-0000-0000-0000-000000000002",
      "organisationId": "00000000-0000-0000-0000-000000000002",
      "organisationName": "BTMS",
      "relationshipRole": "Employee"
    }]
  }'
echo
echo "Registered btms-tester@example.com"
