---
title: "Update partially and return fully in Go"
date: 2021-12-31T20:25:07+07:00
tags: ["Golang", "Postgres"]
draft: false
---


In typical CRUD applications, it's common these days that your update
APIs work properly on objects in a partial way. You should not enforcing
the client to send the whole object to update just a field anymore. And with
Postgres `returning` clause, we can return all object data despite being
updated only some of them.

Let's say you have to update a Student object, we will define all its fields
as pointers so when the client doesn't send up anything, it will be nil:


```go
type Student struct {
      Name *string
      Age  *int
}
```

We must use pointers here because otherwise, we can't differ default zero values
with not-set values that are sent from the client. To update the record, we
come up with two answers.


## 1. CASE WHEN... with RETURNING

In the database interface, we will choose the fields that need to update and
return all object data when done, we use `pgx` and `scany` package here for
executing query and scanning data back to Go struct:


```go
import (
      "os"
      "github.com/jackc/pgx/v4"
      "github.com/georgysavva/scany/pgxscan"
)


func main() {
      conn, _ := pgx.Connect(context.Background(), os.Getenv("DATABASE_URL"))

      query := `
      UPDATE students
      SET
          name = CASE WHEN $1 = true THEN $2 ELSE name END,
          age = CASE WHEN $3 = true THEN $4 ELSE age END
      RETURNING
          name, age`

      rows, _ := conn.Query(
         ctx, query,
         student.Name != nil, student.Name,
         student.Age != nil, student.Age
      )
      defer rows.Close()

      stud := Student{}

      for rows.Next() {
          _ = pgxscan.ScanRow(&stud, rows)
      }
}
```

This solution looks OK, but we can't validate the object with all fields
available at the same time before updating into the database. Hence the
second approach.


## 2. SELECT first, UPDATE later


No code is needed to explain this method. First you retrieve the object from
the database, then change those fields that need updating (non-nil fields),
do whatever validation required, and then write the whole object back.

Despite we must always do a SELECT before an UPDATE, this should be the
preferred solution.
