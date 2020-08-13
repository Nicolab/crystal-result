# This file is part of "result".
#
# This source code is licensed under the MIT license, please view the LICENSE
# file distributed with this source code. For the full
# information and documentation: https://github.com/Nicolab/crystal-result
# ------------------------------------------------------------------------------

require "spec"
require "../src/result"

def test_ok(res, value)
  res.type.should eq :ok
  res.ok?.should be_true
  res.err?.should be_false
  res.class.type.should eq :ok
  res.class.ok?.should be_true
  res.class.err?.should be_false
  res.value.should eq value
  res.unwrap.should eq value
end

def test_err(res, exception)
  res.type.should eq :err
  res.ok?.should be_false
  res.err?.should be_true
  res.class.type.should eq :err
  res.class.ok?.should be_false
  res.class.err?.should be_true
  res.value.should eq exception

  expect_raises(
    Exception,
    exception.is_a?(String) ? exception : exception.message
  ) do
    res.unwrap
  end
end
