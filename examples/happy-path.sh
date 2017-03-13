#!/bin/bash

set -e

EMAIL=${EMAIL:-'email@domain.com'}
ACCOUNT_KEY_LENGTH=${ACCOUNT_KEY_LENGTH:-'2048'}
DOMAIN=${DOMAIN:-'domain.com'}
DOMAIN_ALT=${DOMAIN_ALT:-'www.domain.com'}
DOMAIN_KEY_LENGTH=${DOMAIN_KEY_LENGTH:-'3072'}
DOMAIN_DAYS_TO_RENEW=${DOMAIN_DAYS_TO_RENEW:-'60'}
HR80='################################################################################'

if [ -z "$CLOUDFLARE_KEY" ]; then
	echo 'CLOUDFLARE_KEY must be set'
	exit 1
fi

echo "$HR80"
echo "EMAIL                $EMAIL"
echo "ACCOUNT_KEY_LENGTH   $ACCOUNT_KEY_LENGTH"
echo "DOMAIN               $DOMAIN"
echo "DOMAIN_ALT           $DOMAIN_ALT"
echo "DOMAIN_KEY_LENGTH    $DOMAIN_KEY_LENGTH"
echo "DOMAIN_DAYS_TO_RENEW $DOMAIN_DAYS_TO_RENEW"
echo "CLOUDFLARE_KEY       [OK]"
echo "$HR80"

while true
do
	read -p "Looks good? [yN]" yn
	case $yn in
		[Yy]* ) break;;
		* ) exit;;
	esac
done

# Create a domain key.
docker run --rm -v "$PWD:/acme" xfrocks/acme.sh --debug --staging \
	--createDomainKey \
	--keylength  "$DOMAIN_KEY_LENGTH" \
	--domain "$DOMAIN"

# Create a certificate signing request from existing domain key.
# Multiple alternative domains can be included within one CSR.
docker run --rm -v "$PWD:/acme" xfrocks/acme.sh --debug --staging \
	--createCSR \
	--domain "$DOMAIN" --domain "$DOMAIN_ALT"

# Show the CSR.
docker run --rm -v "$PWD:/acme" xfrocks/acme.sh --debug --staging \
	--showcsr \
	--csr "./$DOMAIN/$DOMAIN.csr"

# Create an account key.
docker run --rm -v "$PWD:/acme" xfrocks/acme.sh --debug --staging \
	--createAccountKey \
	--accountkeylength "$ACCOUNT_KEY_LENGTH"

# Register the account using existing account key.
docker run --rm -v "$PWD:/acme" xfrocks/acme.sh --debug --staging \
	--registeraccount \
	--accountemail "$EMAIL"

# Issue a certificate using registered account and existing CSR.
# Below example uses DNS challenge with CloudFlare API.
# It's possible to issue without registering account / generate CSR,
# those steps will be done automatically with default settings.
docker run --rm -v "$PWD:/acme" \
	-e CF_Key="$CLOUDFLARE_KEY" \
	-e CF_Email="$EMAIL" \
	xfrocks/acme.sh --debug --staging \
		--issue \
		--dns dns_cf \
		--domain "$DOMAIN" --domain "$DOMAIN_ALT" \
		--days "$DOMAIN_DAYS_TO_RENEW"

# List our certificates
docker run --rm -v "$PWD:/acme" xfrocks/acme.sh --debug --staging \
	--list

# Renew certificates.
# Use --force to renew right away otherwise this command will most likely do nothing.
docker run --rm -v "$PWD:/acme" xfrocks/acme.sh --debug --staging \
	--renewAll \
	--days "$DOMAIN_DAYS_TO_RENEW"