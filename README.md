# docker pull xfrocks/acme.sh
Lightweight acme.sh container, about 10MB in image size.

### Issue a certificate with CloudFlare
```
  docker run --rm -v "/path/for/acme:/acme" \
    -e CF_Key="xxx" \
    -e CF_Email="cf@domain.com" \
    xfrocks/acme.sh \
      --issue \
      --dns dns_cf \
      --domain "domain.com" --domain "www.domain.com"
```

### Renew certificates
```
  docker run --rm -v "/path/for/acme:/acme" xfrocks/acme.sh --renewAll
```

See our [examples](https://github.com/daohoangson/docker-acme.sh/tree/master/examples) for more.
