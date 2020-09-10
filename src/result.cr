# This file is part of "result".
#
# This source code is licensed under the MIT license, please view the LICENSE
# file distributed with this source code. For the full
# information and documentation: https://github.com/Nicolab/crystal-result
# ------------------------------------------------------------------------------

# Get the `Result` value (unwrapped) or force the caller to return `Err`
# (if `Err`, the rest of the code isn't executed).
#
# ```
# # With a `Result` instance
# def something(res : Result) : Result
#   # Try to unwrap original value.
#   # If result is an error, here *something* method returns this `Err` instance.
#   data = try!(res)
#
#   # Executed if `try!` (above) has returned the original value.
#   pp "does something"
#
#   # Original value
#   pp data
#
#   # Wrap data into a `Result` struct:
#
#   # Returns success
#   # `Ok` / `OkType::Done`
#   Ok.done data
#
#   # Or returns an error
#   # `Err` / `ErrType::Fail`
#   Err.fail "Oops!"
# end
# ```
macro try!(result)
  %res = {{result}}

  if %res.ok?
    %res.unwrap
  else
    # returns error
    return %res
  end
end

# Try to unwrap *value* (like `Result#unwrap`).
# If value is not a `Result` (`Ok` or `Err`), *value* is simply forwarded.
# > NOTE: To proceed, this macro checks if *value* `responds_to` `unwrap` method.
#
# ```
# res = Ok.done("hello")
# value = unwrap!(res) # => "hello"
#
# res = Err.fail("Oops")
# value = unwrap!(res) # => raise Exception.new "Oops"
#
# foo = "bar"
# value2 = unwrap!(foo) # => "bar"
# ```
macro unwrap!(value)
  {{value}}.responds_to?(:unwrap) ? {{value}}.unwrap : {{value}}
end

# Takes a *value* and make a `Result`.
#
# * `Ok` (*ok*) instance if *value* does not raise an `Exception`.
# * or force the caller to return `Err` (*err*) if an `Exception` occurred
#   (in this case, the rest of the code isn't executed).
#
# ```
# # With a basic *value*
# def something(value : Number) : Result
#   # Wrap value into a `Result` instance (struct: `Ok` or `Err`).
#   # If an error occurred, here *something* method returns an `Err` instance.
#   res = result!(value)
#
#   # Executed only if `result!` (above) has returned an `Ok` instance,
#   pp "does something"
#   pp res.unwrap # => Number
#
#   res
# end
# ```
macro result!(value, ok = Ok::Done, err = Err::Fail)
  raise ArgumentError.new "#result! - wrong argument ('ok' or 'err')" unless {{ok}}.ok? && {{err}}.err?

  begin
    {{ok}}.new {{value}}
  rescue exception
    return {{err}}.new exception
  end
end

{% begin %}
{%
  ok_types = [
    "Done",
    "Pending",
    "Created",
    "Updated",
    "Destroyed",
  ]

  err_types = [
    "Fail",
    "Input",
    "Conflict",
    "NotAllowed",
    "NotFound",
    "Timeout",
  ]
%}

# Wrap a value into a `Result` (like in Rust).
abstract struct Result(T)
  # Returns the result value.
  abstract def value

  # Unwrap the result `value` (like _Result::unwrap_ in Rust).
  abstract def unwrap

  # `Result` type as a `Symbol` (*:ok* or *:err*).
  abstract def type

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
abstract struct Ok(T) < Result(T)
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
  def self.[](value) : OkType::Done
    self.done(value)
  end

  # :inherit:
  def value
    @value
  end

  # :inherit:
  def unwrap
    @value
  end

  # Defines all Ok `Result` creators.
  {% for type in ok_types %}
    alias {{type.id}} = OkType::{{type.id}}

    # Creates new `Ok::{{type.id}}` instance (alias of `OkType::{{type.id}}`).
    #
    # ```
    # res = Ok.{{type.underscore.id}}(value) # => Ok::{{type.id}}
    #
    # pp res.unwrap
    # # or
    # pp res.value
    # ```
    def self.{{type.underscore.id}}(value) : OkType::{{type.id}}
      {{type.id}}.new value
    end
  {% end %}
end

# `Result` error .
abstract struct Err(T) < Result(T)
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
  def self.[](exception) : Err::Fail
    self.fail(exception)
  end

  # :inherit:
  # Returns a `Exception` or a `String`
  def value
    @exception
  end

  # :inherit:
  # This method raises *exception*.
  def unwrap
    raise @exception
  end

  # Defines all Err `Result` creators.
  {% for type in err_types %}
    alias {{type.id}} = ErrType::{{type.id}}

    # Creates new `Err::{{type.id}}` instance (alias of `ErrType::{{type.id}}`).
    #
    # ```
    # err = Err.{{type.underscore.id}}(exception) # => Err::{{type.id}}
    # ```
    def self.{{type.underscore.id}}(exception) : ErrType::{{type.id}}
      {{type.id}}.new exception
    end
  {% end %}
end

# ------------------------------------------------------------------------------
# Result types
# ------------------------------------------------------------------------------

# All `Ok` types.
module OkType
  {% for type in ok_types %}
    struct {{type.id}}(T) < Ok(T)
      def initialize(@value : T)
      end
    end
  {% end %}
end

# All `Err` types.
module ErrType
  {% for type in err_types %}
    struct {{type.id}}(T) < Err(T)
      def initialize(@exception : T)
      end
    end
  {% end %}
end
{% end %}
