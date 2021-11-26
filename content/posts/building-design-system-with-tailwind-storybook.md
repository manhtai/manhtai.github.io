---
title: "Building a design system with Tailwind and Storybook"
date: 2021-05-07T20:52:25+07:00
tags: ["tailwindcss", "storybook", "design system"]
commentid: 5
draft: false
---

If you don't already know what a design system is, Storybook [tutorial][0]
on design system is a good place to start.

In short, design systems contain reusable UI components that help teams
build complex, durable, and accessible user interfaces across projects.
Storybook is a tool for us to do just that.

Our experience in this process as follows:

#### 1, Generate full Tailwindcss configuration, then matching it with design tokens

We need to fine tune colors, spacing, font sizes and screens at first hand,
the rest can be updated later. The job is quite boring as we have to input
numbers manually from Figma to `tailwind.config.js` file, but it is one-off
job so just do it anyway.

#### 2, Build UI components in Storybook, one by one

This can be built in batch if you had the resources or whenever in need.

#### 3, Publish Storybook as private npm package

We use GitLab package registry to do that. Every releases will be auto published to
the registry as well as the Storybook web for showcase purpose.

#### 4, Install the package and reuse UI components in other projects

For local development, you can use `npm link` to link local Storybook project with
the project you are working on without having to publish the package consecutively.

### Conclusion

For any project started out with a design team to spare, TailwindCSS is
pefectly fit for setting up a "style API" with predefined variables such as colors
or spacing. Along with Storybook for building reusable components and we got
a design system good enough to make our product UI/UX experience become consistent
at scale.


[0]: https://storybook.js.org/tutorials/design-systems-for-developers/react/en/introduction/
