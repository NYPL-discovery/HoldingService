# Holding Service

[![Build Status](https://travis-ci.com/NYPL-discovery/HoldingService.svg?branch=master)](https://travis-ci.com/NYPL-discovery/HoldingService) [![GitHub version](https://badge.fury.io/gh/nypl-discovery%2FHoldingService.svg)](https://badge.fury.io/gh/nypl-discovery%2FHoldingService)

## Purpose

This endpoint receives http requests containing new and updated holding statements, saves them, and passes them on to the configured Kinesis stream

## Running locally

```
rvm use
bundle install
psql -c 'create database test_holdings;' -U postgres
```

The method `init_db` in `holding-schema.rb` defines the schema for the `records` table, which the app will use. You can initialize this table by connecting to the db

```
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['DATABASE'],
  host: ENV['DB_HOST'],
  username: ENV['DB_USERNAME'],
  password: password
)
```

and running `init_db`


Lambdas with native extensions are a little tricky. You will need to bundle in the docker image:

Build the image:
```
docker build -t holding-service .
```

Enter the image:

```
docker run --rm -it -v $PWD:/var/task -w /var/task holding-service
```

In the image, install gems:

```
bundle install --path vendor/bundle --clean
```

You can then `exit` the image and proceed.

To test an event locally:

```
sam local invoke --region us-east-1 --template sam.local.yml --profile nypl-digital-dev --event events/empty.json
```

## Contributing

This repo follows a [PRS-Target-Master Git Workflow](https://github.com/NYPL/engineering-general/blob/a19c78b028148465139799f09732e7eb10115eef/standards/git-workflow.md#prs-target-master-merge-to-deployment-branches)

## Testing

Make sure you have bundle installed outside the docker image.

```
export SET BUNDLE_IGNORE_CONFIG=true; bundle exec rspec
```

## Deployment

Deployment is handled by travis for the following branches:

- `qa`
- `production`


## Managing

Credentials for the database are in the parameter store under `[env]/rds/holding_service/credentials`
