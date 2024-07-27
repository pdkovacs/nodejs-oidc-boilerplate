import { isNil } from "lodash-es";

const KEYCLOAK_URL = isNil(process.env.KEYCLOAK_URL)
	? "http://keycloak.internal"
	: process.env.KEYCLOAK_URL;

const viteDevServerPort = 5173;
const backendServerPort = 45678;

const defaults = {
	serverPort: backendServerPort,
	serverHost: "macmini.internal",
	logLevel: "debug",
	oidcTokenIssuer: `${KEYCLOAK_URL}/realms/my-realm`,
	oidcClientId: "node-boilerplate",
	oidcClientSecret: "xxxxx",
	oidcCallbackUrl: `http://macmini.internal:${viteDevServerPort}/oidc-callback`,
	oidcLogoutUrl: `${KEYCLOAK_URL}/realms/my-realm/protocol/openid-connect/logout`
};

export type AppConfig = typeof defaults;

export const readConfiguration = async (): Promise<AppConfig> => {
	const logLevel = process.env.NODE_OIDC_BPLATE_LOG_LEVEL ?? defaults.logLevel;
	const serverHost = process.env.NODE_OIDC_BPLATE_SERVER_HOST ?? defaults.serverHost;
	const serverPort = isNil(process.env.NODE_OIDC_BPLATE_SERVER_PORT) || process.env.NODE_OIDC_BPLATE_SERVER_PORT.length === 0
		? defaults.serverPort
		: parseInt(process.env.NODE_OIDC_BPLATE_SERVER_PORT, 10);
	const tokenIssuer = process.env.NODE_OIDC_BPLATE_TOKEN_ISSUER ?? defaults.oidcTokenIssuer;
	const clientId = process.env.NODE_OIDC_BPLATE_CLIENT_ID ?? defaults.oidcClientId;
	const clientSecret = process.env.NODE_OIDC_BPLATE_CLIENT_SECRET ?? defaults.oidcClientSecret;
	const callbackUrl = process.env.NODE_OIDC_BPLATE_CALLBACK_URL ?? defaults.oidcCallbackUrl;
	const logoutUrl = process.env.NODE_OIDC_BPLATE_LOGOUT_URL ?? defaults.oidcLogoutUrl;
	return {
		...defaults,
		logLevel,
		serverHost,
		serverPort,
		oidcTokenIssuer: tokenIssuer,
		oidcClientId: clientId,
		oidcClientSecret: clientSecret,
		oidcCallbackUrl: callbackUrl,
		oidcLogoutUrl: logoutUrl
	};
};
