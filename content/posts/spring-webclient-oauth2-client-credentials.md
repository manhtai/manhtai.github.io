---
title: "Spring WebClient Oauth2 with Client Credentials"
date: 2019-10-18T20:16:17+07:00
tags: ["spring", "oauth2", "java"]
draft: false
---


[Spring 5 WebClient][1] is an excellent web client for Spring that can do
reactive API request. Combining with Spring Security Oauth2 Client we can
handle the heavy jobs (ie. request access token, check expiry time, re-request
access token, etc) to Spring Security Oauth2 Client and still had all the
benefits of the reactive web client.

First thing first, we need to include the libraries:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-oauth2-client</artifactId>
</dependency>
```

Then define the beans to use:


```java
@Configuration
public class Oauth2ClientConfig {

    @Bean
    ReactiveClientRegistrationRepository getRegistration(
            @Value("${spring.security.oauth2.client.provider.my-platform.token-uri}") String tokenUri,
            @Value("${spring.security.oauth2.client.registration.my-platform.client-id}") String clientId,
            @Value("${spring.security.oauth2.client.registration.my-platform.client-secret}") String clientSecret,
            @Value("${spring.security.oauth2.client.registration.my-platform.scopes}") String scope
    ) {
        ClientRegistration registration = ClientRegistration
                .withRegistrationId("my-platform")
                .tokenUri(tokenUri)
                .clientId(clientId)
                .clientSecret(clientSecret)
                .authorizationGrantType(AuthorizationGrantType.CLIENT_CREDENTIALS)
                .scope(scope)
                .build();
        return new InMemoryReactiveClientRegistrationRepository(registration);
    }

    @Bean(name = "my-platform")
    WebClient webClient(ReactiveClientRegistrationRepository clientRegistrations) {
        ServerOAuth2AuthorizedClientExchangeFilterFunction oauth = new ServerOAuth2AuthorizedClientExchangeFilterFunction(
                clientRegistrations, new UnAuthenticatedServerOAuth2AuthorizedClientRepository());
        oauth.setDefaultClientRegistrationId("my-platform");
        return WebClient.builder()
                .filter(oauth)
                .build();
    }
}
```

Some things worth noting here are:

- 1, The parameters in `@Value` are default configurations for Spring Security
  Oauth2 Client to work (ie. autowiring), so with some luck you can make it work
  without define a bean for `ReactiveClientRegistrationRepository`.

- 2, `WebClient` bean is qualified with `"my-platform"` so it will not conflict
  with other web clients that you may use in your project.

- 3, I used `AuthorizationGrantType.CLIENT_CREDENTIALS` here, but it should
  work with any authorization grant types.

- 4, I use **constructor injection** instead of **field injection** and it
  is considered better practice, you should read more about that.


Now we can use the WebClient as we are used to:


```java
@Service
public class MyPlatformServiceClient {

    private WebClient webClient;
    private String resourceUri;

    @Autowired
    PlatformServiceClientImpl(@Qualifier("my-platform") WebClient webClient,
                              String resourceUri) {
        this.webClient = webClient;
        this.resourceUri = resourceUri;
    }

    public CompletableFuture<MyResourceModel> getResource(String resourceId) {
        return webClient.get().uri(resourceUri)
                .header("X-Resource-ID", resourceId)
                .header("Content-Type", "application/json")
                .retrieve()
                .bodyToMono(MyResourceModel.class)
                .toFuture();
    }
}
```

You can read more about Spring Security Webflux Oauth2 [here][2].

Enjoy the magic of Spring!


[1]: https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/reactive/function/client/WebClient.html
[2]: https://docs.spring.io/spring-security/site/docs/current/reference/html/webflux-oauth2.html
