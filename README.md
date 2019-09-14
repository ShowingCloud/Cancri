Cancri
======

Robodou - Website for Dome Robotics

--------------
- Quick Note 1: 

WebSocket (at least with Action Cable) doesn't work with HTTP/2 anyway. Investigation shows "HTTP_UPGRADE"=>"websocket" got dropped by Nginx (and probably other CDN services especially on Aliyun CDN) on HTTP/2 but not on HTTP/1.1 (with or without TLS). There isn't a configuration option in Nginx to forcibly prevent HTTP/2 being used within a certain location, nor is it possible to prevent a single domain name using HTTP/2. Some discussions show that the browsers will use a single connection for any specific IP / port pair which prevents mixing HTTP/1.1 (with TLS) and HTTP/2 on the same webserver.

Anyway we now decide to stop at here, before any updates on WebSocket and/or HTTP/2, or new approaches updating Action Cable functionalities onto HTTP/2 Server Push (or something).

BTW on Aliyun CDN neither HTTP/2 nor HTTP/1.1 works (both fail with 404 Page not found). Not sure whether the problem lies on the CDN side, or on the webservers.
