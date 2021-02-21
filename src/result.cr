# This file is part of "result".
#
# This source code is licensed under the MIT license, please view the LICENSE
# file distributed with this source code. For the full
# information and documentation: https://github.com/Nicolab/crystal-result
# ------------------------------------------------------------------------------

{% begin %}
{%
  ok_types = [
    "done",
    "pending",
    "created",
    "updated",
    "destroyed",
  ]

  err_types = [
    "fail",
    "input",
    "conflict",
    "not_allowed",
    "not_found",
    "timeout",
  ]
%}

# Wrap a value into a `Result` (like in Rust).
abstract struct Result(T)
  # Returns the result value.
  abstract def value : T

  # Unwrap the result `value` (like _Result::unwrap_ in Rust).
  abstract def unwrap

  # `Result` type as a `Symbol` (*:ok* or *:err*).
  abstract def type : Symbol

  # `Result` status as a `Symbol` (*:done* or *:fail*, etc).
  abstract def status : Symbol

  # Checks a `status`.
  #
  # ```
  # res.status?(:done)
  # res.status?(:fail)
  # ```
  def status?(s : Symbol) : Bool
    status == s
  end

  # Extract the `Result` state (`type`, `status` and `value`).
  # Inspired by the _Elixir_ lang approach, it's handy for the pattern matching.
  def state : {Symbol, Symbol, T}
    {type, status, value}
  end

  # Returns `true` if current `Result` instance is `Ok`, `false` otherwise.
  def ok? : Bool
    type === :ok
  end

  # Returns `true` if current `Result` instance is `Err`, `false` otherwise.
  def err? : Bool
    type === :err
  end

  # Returns `true` if current `Result` class is `Ok`, `false` otherwise.
  def self.ok? : Bool
    self.type === :ok
  end

  # Returns `true` if current `Result` class is `Err`, `false` otherwise.
  def self.err? : Bool
    self.type === :err
  end
end

# `Result` Ok.
struct Ok(T) < Result(T)
  def initialize(@value : T)
    @status = :done
  end

  # Creates a new `Ok` instance with a custom `status`.
  def initialize(@status : Symbol, @value : T)
  end

  getter status : Symbol

  # `Result` type as a `Symbol`.
  #
  # ```
  # Ok.type # => :ok
  # ```
  def self.type : Symbol
    :ok
  end

  # `Result` type as a `Symbol`.
  #
  # ```
  # res.type # => :ok
  # ```
  def type : Symbol
    :ok
  end

  # Syntax sugar for `Ok.done(value)`.
  #
  # ```
  # Ok["hello"] # => same as Ok.done("hello")
  # ```
  def self.[](value) : Ok
    self.done(value)
  end

  # :inherit:
  def value : T
    @value
  end

  # :inherit:
  def unwrap
    @value
  end

  {% for type in ok_types %}
  # Creates a new `Ok` instance with the status `:{{type.id}}`.
  # This method is a shortcut for `Ok.new :{{type.id}}, value`.
  #
  # ```
  # res = Ok.{{type.id}}(value)
  # res.status # => :{{type.id}}
  #
  # pp res.unwrap
  # # or
  # pp res.value
  # ```
  def self.{{type.id}}(value) : Ok
    Ok.new :{{type.id}}, value
  end
  {% end %}
end

# `Result` error .
struct Err(T) < Result(T)
  def initialize(@exception : T)
    @status = :fail
  end

  # Creates a new `Err` instance with a custom `status`.
  def initialize(@status : Symbol, @exception : T)
  end

  getter status : Symbol

  # `Result` type as a `Symbol`.
  #
  # ```
  # Err.type # => :err
  # ```
  def self.type : Symbol
    :err
  end

  # `Result` type as a `Symbol`.
  #
  # ```
  # res.type # => :err
  # ```
  def type : Symbol
    :err
  end

  # Syntax sugar for `Err.fail(exception)`.
  # *exception* must be an `Exception` or a `String`.
  #
  # ```
  # Err["Oops"] # => same as Err.fail("Oops")
  # ```
  def self.[](exception) : Err
    self.fail(exception)
  end

  # :inherit:
  # Returns a `Exception` or a `String`
  def value : T
    @exception
  end

  # :inherit:
  # This method raises *exception*.
  def unwrap
    raise @exception
  end

  {% for type in err_types %}
  # Creates a new `Err` instance with the status `:{{type.id}}`.
  # This method is a shortcut for `Err.new :{{type.id}}, exception`.
  #
  # ```
  # res = Err.{{type.id}}(exception)
  # res.status # => :{{type.id}}
  #
  # # Raise
  # res.unwrap
  #
  # # Or get the exception value
  # pp res.value
  # ```
  def self.{{type.id}}(exception) : Err
    Err.new :{{type.id}}, exception
  end
  {% end %}
end
{% end %}
