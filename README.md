# GraphqlApiRtr

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Run the app on 2 nodes

Run 

```
iex --sname node_a@localhost -S mix phx.server
```
in the first terminal.

In the second terminal, run
```
PORT=4001 iex --sname node_b@localhost -S mix phx.server