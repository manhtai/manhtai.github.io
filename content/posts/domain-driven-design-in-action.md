---
title: "Domain-Driven Design in Action"
date: 2022-07-27T10:57:01+07:00
tags: ["DDD", "Golang"]
draft: false
---


## 1. Domain

**Domain** is the subject area to which the user applies a program.

## 2. Model

A domain contains one or many **domain models** which are systems of
abstractions that describes selected aspects of a domain and can be
used to solve problems related to that domain.

Domain models can be:

- An entity
- A value object
- An aggregate

You can read more about DDD on the [Wikipedia][0] page.


## 3. Entity

Now to begin the "in action" part, let's say we have to implement an
e-commerce system with Products, buyers can create Orders to buy things
which are those Products.

We define 3 entities here to hold corresponding model data:


```go
type Product struct {
    ID    string
    Name  string
}

type Order struct {
    ID    string
    Email string
    Name  string
}

type OrderItem struct {
    ID        string
    OrderID   string
    ProductID string
}
```

Those entities may reside on the `entity` subfolder or on the root of your
current service.


## 4. Repository

This will be the store layer. Repositories only know about persist and
retrieve entities from storage, simple as that, no business logic here.


```go
type ProductRepository interface {
    Create(ctx context.Context, prd entity.Product) error
    Retrieve(ctx context.Context, id string) (prd entity.Product, error)
}

type OrderRepository interface {
    Create(ctx context.Context, ord entity.Order) error
    Retrieve(ctx context.Context, id string) (entity.Order, error)
}
```

The storage may be a SQL or a NoSQL database, it's not the responsibility
of interfaces. That's the implementation detail.

Repositories will be on the `store` folder.


## 5. Service

This is where the business logic happens. We can list some of the logic for
our e-commerce use case here:

- Create, Retrieve, List, Update, Delete a Product
- Create, Pay for, Retrieve an Order

We can see 2 kinds of action here: read-only actions and write (and/or read)
actions. We can separate them into 2 interfaces, or just combine them into
one.


```go
type ProductService interface {
    Create(ctx context.Context, prs entity.ProductParams) error
    Retrieve(ctx context.Context, id string) (entity.Product, error)
}

type OrderService interface {
    Create(ctx context.Context, ord entity.OrderParams) error
    Retrieve(ctx context.Context, id string) (entity.Order, error)
    Pay(ctx context.Context, id string) error
}
```

Services will call to Repositories or other Services to do their job. They
don't talk directly with store layer.

Services should be on the `svc` folder.


## 6. Presentation

This is the window from our application to the outside world and vice versa.

For http web applications, this place is where we define routes, validate
authentication, map from `http.Request` to internal parameters which are used
to call the Services, then get the results and map them back to `http.Response`.

For task workers, this is where we define worker pool size and fire up child
processes to do the work. They all call to Services, no funny logic here.

Let's define the API interface for our e-commerce website:

```go
type ProductAPI interface {
    Create(w http.ResponseWriter, r *http.Request) error
    Retrieve(w http.ResponseWriter, r *http.Request) error
}

type OrderAPI interface {
    Create(w http.ResponseWriter, r *http.Request) error
    Retrieve(w http.ResponseWriter, r *http.Request) error
    Pay(w http.ResponseWriter, r *http.Request) error
}
```

And then maker some routes from them, we use [chi][2] router here for simple
routing:


```go
func NewProductRouter(api ProductAPI) mux.Router {
    r := chi.NewRouter()

    r.Post("/", api.Create)
    r.Get("/{id}", api.Retrieve)

    return r
}

func NewOrderRouter(api OrderAPI) mux.Router {
    r := chi.NewRouter()

    r.Post("/", api.Create)
    r.Get("/{id}", api.Retrieve)
    r.Post("/{id}", api.Pay)

    return r
}
```

APIs should go to `api` folder, workers, well, the `worker` one.


## 7. Wire them all together

After defining all the necessary interfaces, our Go code will compile just
fine. And we can use [Go Swagger][1] to generate the Swagger specification
first. And then work on the implementation later.

Let's wire our APIs together in the main package:


```go
func main() {
    postgresPool := NewPostgresPool(...)

    productRepo := NewProductRepository(postgresPool)
    orderRepo := NewOrderRepository(postgresPool)

    productSvc := NewProductService(productRepo)
    orderSvc := NewOrderService(productRepo, orderRepo)

    productAPI := NewProductAPI(productSvc)
    orderAPI := NewOrderAPI(orderSvc)

    productRouter := NewProductRouter(productAPI)
    orderRouter := NewOrderRouter(orderAPI)

    router := chi.NewRouter()

    router.Mount("/products", productRouter)
    router.Mount("/orders", orderRouter)

    http.ListenAndServe("localhost:8080", router)
}
```

That's it! The most simple full-fledged DDD program ever! It may look
tedious for simple program, but when things get big, DDD with separated layers
really help.


[0]: https://en.wikipedia.org/wiki/Domain-driven_design
[1]: https://goswagger.io/generate/spec.html
[2]: https://github.com/go-chi/chi
