---
title: "Spring Websocket Server"
date: 2019-10-30T22:32:20+07:00
tags: ["spring", "websocket", "java"]
draft: false
---

To include a WebSocket endpoint to our Spring Boot application, first you need
to include the starter package:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

To configure WebSocket server, we need to define a configuration:

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/websocket")
                .addInterceptors(new HandshakeInterceptor())
                .setAllowedOrigins("*")
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/channel");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(new ChannelInterceptor());
    }
}
```


**registerStompEndpoints()** is the method to register endpoints for our
WebSocket server, in which the first HTTP handshake happens. Here we can use
a `HanshakeInterceptor()` to insert some custom attributes for using when
first WebSocket interaction initializes, for example the WebSocket endpoint
path.

**configureMessageBroker()** is used to add channel paths, so our WebSocket
clients can subscribe to.

**configureClientInboundChannel()** is where WebSocket connection make first
CONNECT request, then SUBSCRIBE to a channel, etc. `ChannelInterceptor()` is
the place for authorization & authentication our users before sending and
receiving messages. In here we can get the attributes we've set before in
`HandshakeInterceptor()` instance. Bear in mind that because we do auth in
first CONNECT request of WebSocket connection, we have to make the WebSocket
endpoints whitelisted in any auth required matchers (Spring Security matchers
for instance).

Believe or not, that is all we need to setup a WebSocket server, you now can
setup a WebSocket handler and enjoy the magic of Spring.
