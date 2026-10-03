//origin-response: CORS for allowed_origin plus the security headers; origin-request: the User-Agent becomes the origin secret the site bucket's policy requires.
'use strict';

exports.handler = async (event) => {
  const allowedOrigin = '${ALLOWED_ORIGIN}';
  const referSecret   = '${SECRET}';

  const cfEvent = event.Records[0].cf;

  if (cfEvent.response) {
    const response = cfEvent.response;
    const headers  = response.headers;

    headers['access-control-allow-origin'] = [
      { key: 'Access-Control-Allow-Origin', value: allowedOrigin }
    ];
    headers['access-control-allow-methods'] = [
      { key: 'Access-Control-Allow-Methods', value: 'GET, POST, OPTIONS, DELETE, PUT' }
    ];
    headers['access-control-allow-headers'] = [
      { key: 'Access-Control-Allow-Headers', value: 'Content-Type, Authorization' }
    ];
    headers['access-control-allow-credentials'] = [
      { key: 'Access-Control-Allow-Credentials', value: 'true' }
    ];

    headers['strict-transport-security'] = [
      { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubdomains; preload' }
    ];
    headers['x-content-type-options'] = [
      { key: 'X-Content-Type-Options', value: 'nosniff' }
    ];
    headers['x-xss-protection'] = [
      { key: 'X-XSS-Protection', value: '1; mode=block' }
    ];
    headers['referrer-policy'] = [
      { key: 'Referrer-Policy', value: 'same-origin' }
    ];

    return response;
  }

  if (cfEvent.request) {
    const request = cfEvent.request;
    request.headers['user-agent'] = [
      { key: 'User-Agent', value: referSecret }
    ];
    return request;
  }

  return {};
};
