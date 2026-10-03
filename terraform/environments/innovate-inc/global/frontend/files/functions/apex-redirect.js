function handler(event) {
  var request = event.request;
  if (request.headers.host.value.toLowerCase() !== '${APEX}') {
    return request;
  }

  var query = [];
  for (var key in request.querystring) {
    var param = request.querystring[key];
    (param.multiValue || [param]).forEach(function (item) {
      query.push(key + '=' + item.value);
    });
  }

  return {
    statusCode: 301,
    statusDescription: 'Moved Permanently',
    headers: {
      location: { value: 'https://${WEB_FQDN}' + request.uri + (query.length ? '?' + query.join('&') : '') },
    },
  };
}
