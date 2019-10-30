---
title: "Why I love writing SQL in Spring Boot apps"
date: 2019-10-30T23:03:19+07:00
tags: ["spring", "jpa", "sql", "java"]
draft: false
---

Why do we have to write raw SQL in the ORM world? Because it's efficient,
elegant and type safety. Who wouldn't want that? Efficient, you may nod
slightly, but elegant and type safety, aren't it? Yes it is, if you use
[JPQL][1] in combination with [SpEL][2].

JPQL uses the entity object models instead of database tables to define a
query. It is not really raw SQL you might say, but it got all the syntax of
a raw SQL query. And because it is based on entity models, it is strong type
and it ensure type safety for us (i.e it won't start application if we use
wrong type in our query).

In addition to that, we can use SpEL to write expressions directly in queries
using a subset of Java code. Let's take a look at an example:


```java
@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    @Query(
            " SELECT new NotificationResponse(" +
                    "   n.id, n.title," +
                    "   CASE" +
                    "     WHEN (u.id IS NULL) THEN FALSE" +
                    "     ELSE u.isRead END," +
                    "   n.createTime) " +
                    " FROM Notification n " +
                    " LEFT JOIN UserNotification u ON " +
                    "   u.notificationId = n.id" +
                    "   AND u.userId = :#{#filter.userId}" +
                    "   AND u.userType = :#{#filter.receiverType}" +
                    " WHERE " +
                    "   n.receiverType = :#{#filter.receiverType}" +
                    " GROUP BY n.id" +
                    " ORDER BY n.createTime DESC"
    )
    Page<NotificationResponse> getNotifications(NotificationFilter filter, Pageable pageable);
}
```

Here **Notification** and **UserNotification** are two entity models
corresponding to two tables in database and we can join them using ON
condition as in raw SQL. All statements may look familiar to you, except some
weird `:#{#filter.fieldName}` annotations. They are SpEL expressions that use
Java reflection to inject field values of notification filter into the query.
You can use either private field names or public get methods to get the values
out of filter param.

Something else worth noting here is we don't need to specify `COUNT` query,
JPA will do that for us, but we can customize it of course, and sometime it is
a must.

The last parameter of `getNotifications()` method is a Pageable instance, JPA
will automatically using `LIMIT` and `OFFSET` to do pagination for us, hence
the returning type of the query is `Page<NotificationResponse>`.

I am very comfortable with writing queries in SQL so I am very happy with this
setup, and I hope you will enjoy it too: the magic of Spring (and JPA)!


[1]: https://en.wikipedia.org/wiki/Java_Persistence_Query_Language
[2]: https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions
