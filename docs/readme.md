# PDF417

![](https://raw.githubusercontent.com/jackpocket/pdf417-elixir/main/sample.png)


A library in pure elixir (no NIFs) to generate PDF417 barcodes. Currently only the text and large number modes are supported.

## Todo

* Add support for the binary modes

## Notes

This library owes a large debt to all the other open source versions of encoders; it's a direct port of the [Ruby version](https://github.com/bnix/pdf417-rb), incorporating some ideas from the [Javascript version](http://bkuzmic.github.io/pdf417-js/).

## Installation

If [available in Hex](https://hex.pm/packages/pdf417), the package can be installed
by adding `pdf417` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pdf417, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pdf417](https://hexdocs.pm/pdf417).
