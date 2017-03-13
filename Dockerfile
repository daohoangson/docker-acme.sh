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
	&& git config user.email "daohoangson@gmail.com" \
	&& git cherry-pick 81532f375ea6f9b55e19b07bbe1c106f3d164b19 \
	&& ./acme.sh --install --nocron \
	&& apk del $ACME_SH_BUILD_PACKAGES \
	&& (rm "/tmp/"* 2>/dev/null || true) \
	&& (rm -rf /var/cache/apk/* 2>/dev/null || true)

VOLUME ["/acme"]
WORKDIR /acme
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]