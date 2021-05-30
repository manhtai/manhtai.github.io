---
title: "Maintain Ecto many-to-many associations in Phoenix template"
date: 2021-05-30T10:54:27+07:00
tags: ["Ecto", "Phoenix", "Elixir", "Memoet"]
draft: false
---


While building Today collection feature for [Memoet][0], I encounter a
many-to-many relation problem in Ecto: how to edit the relationship using
only Phoenix template form.

## The models

We got a Deck model, which contains many notes of the same topic, as follow:

```
schema "decks" do
  field(:name, :string)
  has_many(:notes, Note)

  timestamps()
end
```

Now we create a new Collection model, which will contains many decks for us to
learn all notes in those decks at once, aka cross-deck learning:

```
schema "collections" do
  field(:name, :string)

  timestamps()
end
```

Now a collection will contains many decks, and a deck may belong to many
collections, so that is a typical many-to-many relation. We define a mediate
model for that:


```
schema "decks_collections" do
  belongs_to(:collection, Collection)
  belongs_to(:deck, Deck)

  timestamps()
end
```

We will work mostly from the collection onward, i.e. adding decks from one
collection, not adding collections to one deck, so we only need to add the
association to Collection model:

```
schema "collections" do
  field(:name, :string)

  has_many(:decks_collections, DeckCollection, on_replace: :delete)
  has_many(:decks, through: [:decks_collections, :deck], on_replace: :delete)

  timestamps()
end

def changeset(col_or_changeset, attrs) do
  col_or_changeset
  |> cast(attrs, [:name])
  |> cast_assoc(:decks_collections)
end
```

`cast_assoc` in the `changeset` function is responsible for creating new or
updating the old relations when in need. And we use `has_many` with
`on_replace: :delete` to replace all relations at once for that matter.

If you want to add collections to a deck, define similar associations in the
Deck model.

The models are all looking good now.

## The template

To display current decks in one collection and allow users to edit the
relations, we need two lists of decks:

- All available decks which can be added to a collection
- All decks which currently belongs to a collection

```
all_decks = Deck
            |> Repo.all()
col_decks = collection.decks
```

And in the collection's edit template, we display the relation using checkbox
inputs:

```
<%= for deck <- @all_decks do %>
  <label
    <input
      <%= if Deck.member?(@col_decks, deck), do: "checked" %>
      name="collection[deck_ids][]"
      type="checkbox"
      value="<%= deck.id %>"
    >
    <%= deck.name %>
  </label>
<% end %>
```

Data for `collection[deck_ids][]` name will become `%{"collection" => %{"deck_ids" =>
[1, 2, 3]}}` when passing to controller. And we got the deck IDs we need to keep only
these decks in the collection. So in our controller, we got:


```
def update(conn, %{"collection" => collection_data, "id" => collection_id} = _params) do
  decks_collections =
    case collection_data do
      %{"deck_ids" => deck_ids} ->
        deck_ids
        |> Enum.map(fn deck_id ->
          %{
            "deck_id" => deck_id,
            "collection_id" => collection_id,
          }
        end)

      _ ->
        []
    end

  params = %{
    "decks_collections" => decks_collections
  }

  Collection
  |> Repo.get!(collection_id)
  |> Collection.changeset(params)
  |> Repo.update()
end
```

When we pass `%{"decks_collections" => [%{"deck_id" => 1, "collection_id" => 1}]}` to
`changeset` function, Ecto will handle all the hard works for us, following
the rules we have defined before in our models.

## The end

That's it. All is done without a single line of JavaScript. Visit
[memoet.com][1] and see the Today collection for yourself!


[0]: https://github.com/memoetapp/memoet
[1]: https://memoet.com
