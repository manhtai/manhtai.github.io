---
title: "Postgres: Update object items on JSONB array"
date: 2022-04-25T17:12:38+07:00
tags: ["Postgres"]
draft: false
---


## Problem:

We have a table with a JSONB array column `data` which contains many objects:

```json
[
  {"type": "dog", "id": "dog-1"},
  {"type": "cat", "id": "cat-1"}
]
```

How do we change the name field from `"type"` into `"kind"` and keep all related data?

Let a assume table `animals` has 2 columns: `id` and `data`.


## Answer:


```sql
UPDATE animals
SET data = new.data
FROM (
         SELECT id,
                jsonb_agg(
                        jsonb_build_object(
                                'id', elem -> 'id',
                                'kind', elem -> 'type'
                            )
                    ) AS data
         FROM animals,
              jsonb_array_elements(CASE jsonb_typeof(data) WHEN 'array' THEN data ELSE '[]' END) AS elem
         WHERE data -> 0 -> 'kind' IS NULL
         GROUP BY animals.id
     ) new
WHERE animals.id = new.id;
```
