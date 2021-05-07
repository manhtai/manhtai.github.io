---
title: "Sortablejs for Bulk Editing"
date: 2020-12-25T22:05:11+07:00
tags: ["sortablejs", "vuejs"]
draft: true
---

SortableJs is one of the most popular drag-and-drop library in the wild, and AhaSlides uses its Vue wrapper for drag & drop slides in the left side bar from the beginning.

Recently, we got a new request from users that makes the drag & drop multiple slides possible, as well as allow presenter to edit multiple slides at the same time. Forturnately, Sortable has just supported multi-drag feature from last year, but unforturnately, Vue-Draggable hasn’t supported yet. Turn out there was an unmerged pull request from long time ago which intends to do just that.

What is our solution then? We fork it out, and maintain the patch in our repo. Along the way, we have to make some more patches to support select and deselect items manually. In the future, we might want to clone the code into our presenter app and maintain it there.

There are some notes which will need to know to work with the bulk editing feature:

#### 1, We keep track of 2 states for each slide: Active & Selected

Active state means that the slide is currently in concern, whenever you edit the slide content, you are editing the active slide content. You can only have one active slide in each presentation.

Selected state means that the slide is selected for drag and drop, and maybe for bulk editing, you can have multiple slides selected, and edit them all at once.

Active state is maintained in our app code, selected state is maintained in Sortable code. It is quite a bit messy to keep track of selected state and keep them in sync with active one.

#### 2, What does it really mean by “selected”?

SortableJS maintains an array to keep track of selected ones, when you select a slides, it will push the slide DOM into the array and toggle the selected class on the element, then, dispatch a select event to whomever it may concern.

Select event is just an after action, and is manually triggerred by SortableJS so other plugins / components may listen to them. It is not like a click event that you can trigger to simulate a select action.

#### 3, New slide is just a placeholder

They can’t be editted, so get rid of them in bulk editing. I’ve tried to handle new slides as real ones, but gain nothing doing that.

They have no id, so you can’t depend on slide.id to make them active. You have to use their index in the slides array. When there is no id, we check slide order to toggle active class.

#### 4, Ordinal sorting is a fun problem

Your original array has the order [1, 2, 3, 4], if you drag 3, 4 and drop them between 1 and 2, what should the new orders be?

The first solution should be update all slides’ orders so they will be [1, 2, 3, 4] again, but it would be too much operations in our database.

The second method is use average number, first you drop 3, it becomes [1, 1.5, 2], then you drop 4, it becomes [1, 1.5, 1.75, 2], you only have to change two slides instead of four.

So what did we use? Neither of them. We use fraction instead. Find out more here.

#### 5, Grid layout is perfect fit for Grid view

display: flex had a problem with last row alignment, you can find some insights here. To make this go away, I have to change layout from flex in single view into grid layout in grid view.

display: grid has some problems on its own, but acceptable in our case.

To be discuss: While working on the bulk editing feature, I have to rewrite tons of API & FE code to change from single edit to multiple edit. In normal CRUD app, we would never think about writing an API that work for multiple items in a single request from the beginning, the question is, should we, or should we not?
