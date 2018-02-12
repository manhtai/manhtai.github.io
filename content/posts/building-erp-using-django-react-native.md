---
title: "How we build a working ERP system using Django and React Native in 3 months"
date: 2018-01-28T16:53:15+07:00
tags: ["django", "react native"]
draft: false
---

The title may seem too promising, and but it is a working ERP, not a complete
one, we are still having many things to build and improve.

## Overview

Within 3 months, 2 developers, we managed to build a web UI (using [Django][1]) and
a mobile app (using [React Native][2]), with this core business flow:

> Quotation > Sales Order > Purchase Order

A little bit about above flow looks like this.

The sales staffs create Quotations when they are selling Products to Customers,
usually over telephones. They make an assignment to services staff in the same
screen they create the quotation. This services staff will instantly receive a
notification about this new quotation assigned for them through an app, and
know when and where they should meet the customer.

When the services staff delivers service to customer, they will make a sales
order in their app, print an invoice using a thermal printer and get the money.
They can do all of that offline, and do it fast.

After that, they must be online to sync the sales orders back to our server.
In there, some purchase orders will be created automatically base on the products
customers bought from us. Those purchase orders will be sent to corresponding
suppliers for purchasing.

## The fail

I am the technical lead of this new ERP project, and the first task is to do
research about ERP frameworks that already out there in the market. We don't
think about create one from scratch at first because it must be too big for us
to handle. We are only a small startup team after all.

After a day or two playing around, two most promising ones I found are [Odoo][10]
and [ERPNext][11]. But soon I drop Oddo because it's too big and not very
"open" anymore in the sense of open source softwares.

And then, after that, there was 2 sweaty weeks of trying to fit our business
model in to ERPNext. Finally, I must give up. It's not our business flow is too
complex, but the devil is in the details. I need freedom to create models and
calculations for the system that ERPNext just does not allow.

*We must create all from scratch*, I told our CTO. And he agreed.

## The web

I choose Django mainly for its battery-included features: ORM & admin interfaces.
All we need to do is to declare models, and it will generate migration files
and fire up an admin page for us, so we can create and change things fast.

We use [Grappelli][3] for admin style instead of default one, and use admin UI as
default UI for our staffs. It does not look fancy, but simple and configurable.

## The API

The first thing in mind when we start the project is the mobile app, not the
web UI, hence the API, and Django with its famous [REST framework][4] suits our
need very well. At least I thought that, because I have many experiences working
with this.

But then, something pop up in my eyes: [Graphql][5], and it looks shiny!
After digging around, I found this [Graphene][6] for Python, give it a try, and
the choice has been made.

Graphql help us build API faster & easier than REST, just declare your schema
and boom, you got a full-fledged API!

## The app

At first our team has only one mobile dev, and he is using [Ionic][7] for some
of our apps. I myself am a backend developer most of the time, so I need
another man for the project. I can't take the only mobile developer we had because
he is very busy himself. Our CTO suggests that I should use the same mobile framework
we already use, i.e. Ionic, so I can get support from the experienced one.

I also thought that myself, but then, you know, many things pop up in our
little eyes these days. You already know what it is this time: React Native.
As I just said, our team only had one mobile developer, but fortunately, all
our frontend dev already use a frontend framework at another project of ours:
[Vuejs][8]. And React Native is just [Reactjs][9] in the mobile world, and it
must be the same!

When I mention React Native, one of our dev shows the interest, so I invited
him to join, and it turns out he and I made an awesome team! He
builds most parts of the app, I only help for some. And the most tricky thing
I face is to print Vietnamese characters to thermal printer. I really should write
a post about that later.

## The result

We had a working ERP system for recording our core business activities that we
can take advantages of by using other data centric tools for making reports,
alerts, forecast, etc. All fancy things that we imagined we can do with the data,
now we can do it.

## The ongoing

There are many parts of the system need to be added: CRM, Call center, etc.
But really, choosing the right tools from the start is the key for any success
later. Good tools are all around, just pick one for your need!


[1]: https://www.djangoproject.com
[2]: https://facebook.github.io/react-native/
[3]: http://grappelliproject.com/
[4]: http://www.django-rest-framework.org/
[5]: http://graphql.org/learn/
[6]: http://graphene-python.org/
[7]: https://ionicframework.com/
[8]: https://vuejs.org/
[9]: https://reactjs.org/
[10]: https://www.odoo.com/
[11]: https://erpnext.com/
