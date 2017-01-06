FROM alpine:edge
MAINTAINER Dao Hoang Son <daohoangson@gmail.com>

ARG ACME_SH_VERSION

ENV ACME_SH_BUILD_PACKAGES \
	git

ENV ACME_SH_RUN_PACKAGES \
	curl \
	openssl

RUN apk add --no-cache --update $ACME_SH_BUILD_PACKAGES $ACME_SH_RUN_PACKAGES \
	&& cd /tmp \
	&& git clone https://github.com/Neilpang/acme.sh.git \
	&& cd ./acme.sh \
	&& git -c advice.detachedHead=false checkout ${ACME_SH_VERSION} \
	&& ./acme.sh --install --nocron \
	&& apk del $ACME_SH_BUILD_PACKAGES \
	&& (rm "/tmp/"* 2>/dev/null || true) \
	&& (rm -rf /var/cache/apk/* 2>/dev/null || true)

# Fix issue with dns_cf in v2.6.4
# It has been fixed by https://github.com/Neilpang/acme.sh/commit/c7b16249b88f682fed44f84ef772625bb69b0eba
# TODO: remove this after future version bump
RUN sed -i'' 's/\$_SCRIPT_HOME\/\$_hookdomain\/\$_hookname/\$_SCRIPT_HOME\/\$_hookcat\/\$_hookname/g' /root/.acme.sh/acme.sh

VOLUME ["/acme"]
WORKDIR /acme
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]