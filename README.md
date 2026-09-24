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

Create `.env` file in the root of the project and provide necessary secrets (copy `.env.example`).

## Usage

Start as follows:

```bash
docker compose up -d --build
```

Stop as follows:

```bash
docker compose down
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
