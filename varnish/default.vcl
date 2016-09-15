vcl 4.0;

backend frontend {
    .host = "frontend";
    .port = "80";
}

backend api {
    .host = "api";
    .port = "80";
}

sub vcl_recv {
  if (req.url ~ "^/api" || req.url ~ "^/log(in|out)" || req.url ~ "^/register" || req.url ~ "^/invoice") {
    set req.backend_hint = api;
    set req.url = "/public" + req.url;
  } else {
    set req.backend_hint = frontend;
  }
  return (pass);
}
