# Holding Service

## Purpose

This endpoint receives http requests containing new and updated holding statements, saves them, and passes them on to the configured Kinesis stream

## Running locally

```
rvm use
bundle install
psql -c 'create database test_holdings;' -U postgres
```

To test an event locally:

```
sam local invoke --region us-east-1 --template sam.local.yml --profile nypl-digital-dev --event events/empty.json
```

## Contributing

## Testing

```
bundle exec rspec -fd
```

## Deployment

Deployment is handled by travis for the following branches:

- `qa`
