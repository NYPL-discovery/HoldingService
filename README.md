# Holding Service

## Purpose

This endpoint receives http requests containing new and updated holding statements, saves them, and passes them on to the configured Kinesis stream

## Running locally

```
rvm use
bundle install
psql -c 'create database test_holdings;' -U postgres
```
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

## Testing

Make sure you have bundle installed outside the docker image. 

```
export SET BUNDLE_IGNORE_CONFIG=true; bundle exec rspec
```

## Deployment

Deployment is handled by travis for the following branches:

- `qa`
