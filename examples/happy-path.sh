#!/bin/sh

set -e

DEBUG="--debug"
STAGING="--staging"
EMAIL='email@domain.com'
ACCOUNT_KEY_LENGTH=2048
DOMAIN='domain.com'
DOMAIN_ALT='www.domain.com'
DOMAIN_KEY_LENGTH=3072
DOMAIN_DAYS_TO_RENEW=60
CLOUDFLARE_KEY='xxx'

# Create a domain key.
docker run --rm -v "$PWD:/acme" xfrocks/docker-acme.sh \
	"$DEBUG" "$STAGING" \
	--createDomainKey \
	--keylength  "$DOMAIN_KEY_LENGTH" \
	--domain "$DOMAIN"

# Create a certificate signing request from existing domain key.
# Multiple alternative domains can be included within one CSR.
docker run --rm -v "$PWD:/acme" xfrocks/docker-acme.sh \
	"$DEBUG" "$STAGING" \
	--createCSR \
	--domain "$DOMAIN" --domain "$DOMAIN_ALT"

# Show the CSR.
docker run --rm -v "$PWD:/acme" xfrocks/docker-acme.sh \
	"$DEBUG" "$STAGING" \
	--showcsr \
	--csr "./$DOMAIN/$DOMAIN.csr"

# Create an account key, should target staging server for testing.
docker run --rm -v "$PWD:/acme" xfrocks/docker-acme.sh \
	"$DEBUG" "$STAGING" \
	--createAccountKey \
	--accountkeylength "$ACCOUNT_KEY_LENGTH"

# Register the account using existing account key.
docker run --rm -v "$PWD:/acme" xfrocks/docker-acme.sh \
	"$DEBUG" "$STAGING" \
	--registeraccount \
	--accountemail "$EMAIL"

# Issue a certificate using registered account and existing CSR.
# Below example uses DNS challenge with CloudFlare API.
# It's possible to issue without registering account / generate CSR,
# those steps will be done automatically with default settings.
docker run --rm -v "$PWD:/acme" \
	-e CF_Key="$CLOUDFLARE_KEY" \
	-e CF_Email="$EMAIL" \
	xfrocks/docker-acme.sh \
		"$DEBUG" "$STAGING" \
		--issue \
		--dns dns_cf \
		--domain "$DOMAIN" --domain "$DOMAIN_ALT" \
		--days "$DOMAIN_DAYS_TO_RENEW"

# List our certificates
docker run --rm -v "$PWD:/acme" xfrocks/docker-acme.sh \
	"$DEBUG" "$STAGING" \
	--list

# Renew certificates.
# Use --force to renew right away otherwise this command will most likely do nothing.
docker run --rm -v "$PWD:/acme" xfrocks/docker-acme.sh \
	"$DEBUG" "$STAGING" \
	--renewAll \
	--days "$DOMAIN_DAYS_TO_RENEW"