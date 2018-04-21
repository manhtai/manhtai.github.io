---
title: "Python 2to3 Transition"
date: 2018-04-21T12:05:19+07:00
draft: false
tags: ["python", "django"]
---

Recently I've upgraded one of our biggest projects from Python2.7 to Python3.6,
and the process is quite smooth. It tooks me almost 2 days to complete all
conversion needed, while other developers were still doing their dail jobs in
the project.

Steps I made:

- 1, Run `2to3`

- 2, Fix the code so that all the tests passes again.

- 3, Handle outlier cases & write tests for them. Those cases are somewhat
  related to the diffirences between `unicode` & `str`.

Some key notes here:

- 1, Having a solid unit tests system is critical.

- 2, `2to3` did all the heavy works, but you need to know the stuffs to get all
   the shit done.
