# Result

[![CI Status](https://github.com/Nicolab/crystal-result/workflows/CI/badge.svg?branch=master)](https://github.com/Nicolab/crystal-result/actions) [![GitHub release](https://img.shields.io/github/release/Nicolab/crystal-result.svg)](https://github.com/Nicolab/crystal-result/releases) [![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://nicolab.github.io/crystal-result/)

∠(・.-)―〉 →◎ `Result` adds _Monadic Error Handling_ capabilities to [Crystal lang](https://crystal-lang.org), inspired by `Result` in _Rust_ lang, Monad and the _Elixir_ lang approach (state return).

Adapted to be productive in Crystal and [Domain-Driven Design (DDD)](https://en.wikipedia.org/wiki/Domain-driven_design).

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
   dependencies:
     result:
       github: nicolab/crystal-result
       version: ~> 2.0.1 # Check the latest version!
```

2. Run `shards install`

## Usage

```crystal
require "result"
require "result/utils"

# With a basic *value*
def something(value : Number) : Result
  # Wrap value into a `Result` instance (struct: `Ok` or `Err`).
  # If an error occurred, here *something* method returns an `Err` instance.
  res = result!(value)

  # Executed only if `result!` (above) has returned an `Ok` instance,
  pp "does something"
  pp res.unwrap # => Number

  res
end

# With a `Result` instance
def something(res : Result) : Result
  # Try to unwrap original value.
  # If result is an error, here *something* method returns this `Err` instance.
  data = try!(res)

  # Executed if `try!` (above) has returned the original value.
  pp "does something"

  # Original value
  pp data

  # Wrap data into a `Result` struct:

  # Returns success
  # `Ok` / `Ok.status # => :done`
  Ok.done data

  # Or returns an error
  # `Err` / `Err.status # => :fail`
  Err.fail "Oops!"
end

# Try to unwrap a *Result* (like `Result#unwrap`) or forward the value if it is not a `Result`.
res = Ok.done("hello") # or `Ok.new("hello")`
value = unwrap!(res) # => "hello"

res = Err.fail("Oops") # or `Err.new("Oops")`
value = unwrap!(res) # => raise Exception.new "Oops"

foo = "bar"
value2 = unwrap!(foo) # => "bar"
```

To go further, `Result` works wonderfully with [fuzzineer/match-crystal](https://github.com/scatterfish/match-crystal).

```crystal
require "result"
require "result/utils"
require "match-crystal"

res = something()

message = match res.status, {
  :created   => "Created with success",
  :destroyed => "Destroyed with success",
  :pending   => "Pending task",
  :input     => "Bad argument",
  :fail      => "Failed",
  _          => "anything else!",
}

puts message

# other example

message = match res, {
  Ok(String)              => "Ok is a good string",
  res.status? :created    => "Created with success",
  Ok                      => "It's ok",
  Err(ArgumentError)      => "Bad argument",
  res.status? :not_found  => "Not found",
  Err                     => ->{
    puts "Block is supported using Proc syntax"
    "Error occurred"
  },
}

puts message
```

Example with a `case`:

```crystal
message = case res
  when .status? :created
    "Created with success"
  when .status? :destroyed
    "Destroyed with success"
  when .status? :pending
    "Pending task"
  when .status? :input
    "Bad argument"
  when .status? :not_found
    "Not found"
  when .status? :fail
    "Failed"
  when Ok
    "Another success"
  when Err
    "Another error"
  else
    "Anything else!"
  end

puts message
```

Works well with a controller.

## Development

```sh
crystal spec
crystal tool format
```

## Contributing

1. Fork it (https://github.com/Nicolab/crystal-result/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## LICENSE

[MIT](https://github.com/Nicolab/crystal-result/blob/master/LICENSE) (c) 2020, Nicolas Talle.

## Author

| [![Nicolas Tallefourtane - Nicolab.net](https://www.gravatar.com/avatar/d7dd0f4769f3aa48a3ecb308f0b457fc?s=64)](https://github.com/sponsors/Nicolab) |
|---|
| [Nicolas Talle](https://github.com/sponsors/Nicolab) |
| [![Make a donation via Paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PGRH4ZXP36GUC) |
