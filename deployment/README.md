# Deployment

## Configuration

Samples:

`${HOME}/.node-boilerplate.secrets`

```
export NODE_BOILERPLATE_CLIENT_SECRET=XXXXXXXXX
export NODE_BOILERPLATE_TEST_USER_PASSWORD=XXXXXXXXX
export NODE_BOILERPLATE_PRIVILEGED_TEST_USER_PASSWORD=XXXXXXXXX
```

`${HOME}/.node-boilerplate.rc`

```
export PARENT_DOMAIN=<your-domain>.<your-top-level-domain>
export ACM_CERT_DOMAIN='*.'${PARENT_DOMAIN}
export APP_NAME=node-boilerplate
export APP_DOMAIN_NAME=${APP_NAME}.${PARENT_DOMAIN}
export APP_VERSION=latest
```

`${HOME}/.my-aws-config`

```
export AWS_ACCOUNT_ID=XXXXXXXX
export AWS_PROFILE=AdministratorAccess-XXXXXXXX
export AWS_REGION=XXXXXX
```
