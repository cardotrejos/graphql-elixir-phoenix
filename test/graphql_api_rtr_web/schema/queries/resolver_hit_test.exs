defmodule GraphqlApiRtrWeb.Schema.Queries.ResolverHitTest do
  use GraphqlApiRtr.DataCase, async: true

  alias GraphqlApiRtrWeb.Schema

  @all_users_doc """
  query Users($likesEmails: Boolean, $likesPhoneCalls: Boolean, $likesFaxes: Boolean, $name: String, $before: Int, $after: Int, $first: Int ) {
    users (likesEmails: $likesEmails, likesPhoneCalls: $likesPhoneCalls, likesFaxes: $likesFaxes, name: $name, before: $before, after: $after, first: $first) {
     id
     name
     email
      preferences {
        id
        user_id
        likes_emails
        likes_phone_calls
        likes_faxes
      }
    }
  }
  """

  @resolver_hits_doc """
  query ResolverHits($key: Request!){
    resolverHits (key: $key){
      key
      count
    }
  }
  """

  describe "@resolver_hits" do
    test "returns an increased count for a given request after the request has been sent to the server" do
      assert {:ok, %{data: %{"resolverHits" => %{"count" => count, "key" => "RESOLVER_HITS"}}}} =
               Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "RESOLVER_HITS"})

      assert {:ok, %{data: _data}} = Absinthe.run(@all_users_doc, Schema)

      assert {:ok,
              %{data: %{"resolverHits" => %{"count" => new_count, "key" => "RESOLVER_HITS"}}}} =
               Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "RESOLVER_HITS"})

      assert new_count === count + 1
    end
  end
end
