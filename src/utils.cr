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
#   # `Ok` / `Ok.status # => :done`
#   Ok.done data
#
#   # Or returns an error
#   # `Err` / `Err.status # => :fail`
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
# res = Ok.done("hello") # or Ok.new("hello")
# value = unwrap!(res)   # => "hello"
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
macro result!(value, ok = :done, err = :fail)
  begin
    Ok.new {{ok}}, {{value}}
  rescue exception
    return Err.new {{err}}, exception
  end
end
