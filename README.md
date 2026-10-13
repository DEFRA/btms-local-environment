# btms-local-environment

Docker Compose for running BTMS services locally.

- [btms-gateway](https://github.com/DEFRA/btms-gateway)
- [btms-portal-frontend](https://github.com/DEFRA/btms-portal-frontend)
- [cdp-defra-id-stub](https://github.com/DEFRA/cdp-defra-id-stub)
- [trade-imports-cds-simulator-api](https://github.com/DEFRA/trade-imports-cds-simulator-api)
- [trade-imports-data-api](https://github.com/DEFRA/trade-imports-data-api)
- [trade-imports-decision-deriver](https://github.com/DEFRA/trade-imports-decision-deriver)
- [trade-imports-processor](https://github.com/DEFRA/trade-imports-processor)
- [trade-imports-reporting-api](https://github.com/DEFRA/trade-imports-reporting-api)

## Prerequisites

### Dependencies

Install the following:
- [Docker](https://docs.docker.com/engine/)
- [Docker Compose](https://docs.docker.com/compose/)

### Environment variables

None are needed. The portal's sign-in settings default to the local Defra ID stub, using deliberately
fake IDs. To override one, for example to sign in with real Entra ID test credentials, copy
`.env.example` to `.env` and uncomment the lines you need.

To sign in to the portal at <http://localhost:3000>, choose Defra ID and pick `btms-tester@example.com`.
`scripts/cdp-defra-id-stub/register-users.sh` registers that user in the stub on every start. To add
another user, copy its request and use organisation ID `00000000-0000-0000-0000-000000000002`, the one
the portal allows by default.

## Usage

Start as follows:

```bash
docker compose up -d --build
```

Stop as follows:

```bash
docker compose down
```

## With Trade Gateway (TRACES CHEDs)

`compose.tgp.yml` adds the Trade Gateway services, so a CHED created in the TRACES simulator reaches
BTMS the way it does on CDP:

```
simulator ─► trade-gateway ─► trade-gateway-publisher ─► SNS trade_gateway_publisher_ched_updates.fifo
  ─► SQS trade_gateway_publisher_ched_updates_processor.fifo ─► trade-imports-processor ─► trade-imports-data-api
```

Stop `trade-gateway-local-environment` first, since it uses the same ports. Then:

```bash
docker compose -f compose.yml -f compose.tgp.yml up -d
docker compose -f compose.yml -f compose.tgp.yml down
```

The TGP services share this stack's floci and Mongo, and take TGP's usual host ports plus 100:

| Service | Port |
| --- | --- |
| [trade-tracesnt-stub](https://github.com/DEFRA/trade-tracesnt-stub) (simulator, control API at `/control`) | 3100 |
| [trade-gateway](https://github.com/DEFRA/trade-gateway) | 8180 |
| [trade-gateway-publisher](https://github.com/DEFRA/trade-gateway-publisher) | 8185 |
| [trade-traces-poc](https://github.com/DEFRA/trade-traces-poc) | 8090 |
| [trade-imports-quantity-mgmt](https://github.com/DEFRA/trade-imports-quantity-mgmt) | 8186 |

The decision deriver reserves CHED quantity through trade-imports-quantity-mgmt, which calls
trade-gateway. Finalised declarations reach it from the Data API on
`trade_imports_data_upserted_quantity_mgmt`, and it releases their reservations.

Pin images in `.env` with `TRADE_TRACESNT_STUB`, `TRADE_GATEWAY`, `TRADE_GATEWAY_PUBLISHER`,
`TRADE_IMPORTS_QUANTITY_MGMT` and `TRADE_TRACES_POC`. TGP config lives in `config/tgp/`, and the extra floci resources in
`scripts/floci/combined.d/`. The publisher polls for CHED changes every 10 seconds, rather than every
2 minutes as it does in TGP.

Create a CHED in the simulator. The response gives its ID, e.g. `CHEDA.XI.2026.0000001`:

```bash
curl -X POST http://localhost:3100/control/cheds -H "Content-Type: application/json" -d '{
  "exchangedDocument": {"includedNote": {"CHED_TYPE": "A"}, "declaration": {"includedClause": {"PURPOSE": "FREE_CIRCULATION"}}},
  "specifiedConsignment": {
    "consignorParty": {"identifier": "770198", "postalAddress": {"countryId": "XI"}},
    "unloadingBaseportLocation": {"identifier": "GBBEL", "countryId": "XI"},
    "includedConsignmentItem": {"includedTradeLineItem": [{"applicableClassification": {"CN": "0101"}, "originCountry": "AF"}]}}}'
```

Within about 15 seconds it is in the Data API:

```bash
curl -u Developer:developer-pwd http://localhost:8081/traces-cheds/CHEDA.XI.2026.0000001/
```

Seed CHEDs once the stack is up. The publisher's first run only looks back 5 minutes.

To call trade-gateway directly, get a token for one of the principals in its `appsettings.Development.json`:

```bash
curl -X POST http://localhost:8180/local/cognito/token -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "scope=trade-gateway-resource-srv/access" --data-urlencode "sub=test-ched-reader"
```

## Service API documentation

View service API documentation locally as follows:

- [trade-imports-data-api](http://localhost:8081/redoc/index.html)
- [trade-imports-reporting-api](http://localhost:8085/redoc/index.html)

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government licence v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable
information providers in the public sector to license the use and re-use of their information under a common open
licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
