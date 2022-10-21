---
title: "Create unique index on non-unique data"
date: 2022-10-21T09:27:59+07:00
tags: ["sql", "Postgres"]
draft: false
---

The title is a clickbait. You can't do that unless some data migrations were
done.

Let's say we have a font variant table with below schema:

```sql
CREATE TABLE font_variants (
  family  VARCHAR(255)  NOT NULL,
  weight  INT           NOT NULL,
  style   VARCHAR(255)  NOT NULL,
  user_id UUID          NOT NULL
);
```

All is good until after a while, we realize that a variant is unique by
(`family`, `weight`, `style`) and we should enforce that on database level.
The problem is old data were filled up with not unique rows, when we try to
create an unique index like this, it will fail:


```sql
CREATE UNIQUE INDEX font_variants_family_weight_style_idx ON
font_variants(user_id, family, weight, style);
```

We can't make those rows unique unless we change the row data. Fortunately,
browsers are [handling][1] font-weight gracefully and we can do the migration
by changing the weight without huge impact on font display, even if you using
the weight on database for rendering font CSS directly.

Let's increase weight by the duplication number on each duplicated row:

```sql
UPDATE font_variants
SET weight = weight + rn - 1
FROM (SELECT id, row_number() OVER (PARTITION BY user_id, family, weight, style) rn
      FROM font_variants) fv
WHERE font_variants.id = fv.id;
```

We're good to do the unique index creation now.



[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/font-weight#fallback_weights
