---
title: "Get plain JSON from MongoDB in Go"
date: 2021-08-24T11:36:35+07:00
tags: ["Mongo", "Go"]
draft: false
---

When reading data from MongoDB using Go, we encounter a struct with a JSON
generic field that may be an object or an array, which itself may contain nested
objects or arrays.

We only need the plain JSON in this case because we already got the parsing
code to convert the generic JSON object to specific structs.


To hold unprocessed BSON, we declare our field `bson.RawValue`:


```go
type object struct {
        Data bson.RawValue `bson:"data"`
}
```

To parse `Data` field, we just need to use a trial:


```go
var d interface{}

var m bson.M
var a bson.A

e := object.Data.Unmarshal(&m)
d = m

if e != nil {
        _ = object.Data.Unmarshal(&a)
        d = a
}
```

This should work, but it results in all `bson.M` objects becoming `Key`
and `Value` object like this one:

```json
{
    "Key": "key",
    "Value": "value"
}
```

instead of this:

```json
{"key": "value"}
```

This is the behavior of default Mongo decoder registry, so we have to register
a new entry for `bson.M{}`:


```go
rb := bson.NewRegistryBuilder()
rb.RegisterTypeMapEntry(bsontype.EmbeddedDocument, reflect.TypeOf(bson.M{}))
```


### Final working version:


```go
rb := bson.NewRegistryBuilder()
rb.RegisterTypeMapEntry(bsontype.EmbeddedDocument, reflect.TypeOf(bson.M{}))
reg := rb.Build()

var d interface{}

var m bson.M
var a bson.A

e := object.Data.UnmarshalWithRegistry(reg, &m)
d = m

if e != nil {
        _ = object.Data.UnmarshalWithRegistry(reg, &a)
        d = a
}
```
