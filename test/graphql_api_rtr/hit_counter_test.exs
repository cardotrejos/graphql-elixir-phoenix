defmodule GraphqlApiRtr.HitCounterTest do
  use ExUnit.Case, async: true

  alias GraphqlApiRtr.HitCounter

  @request :test_request

  describe "get_hits/ 2 and add_hits/2" do
    test "get_hits/2 returns 0 if a given request has never been made, and add_hits/2 increments the count every time the request is sent" do
      assert HitCounter.get_hits(@request) === 0
      assert :ok = HitCounter.add_hit(@request)
      assert :ok = HitCounter.add_hit(@request)
      assert HitCounter.get_hits(@request) === 2
    end
  end
end
