# This file is part of "result".
#
# This source code is licensed under the MIT license, please view the LICENSE
# file distributed with this source code. For the full
# information and documentation: https://github.com/Nicolab/crystal-result
# ------------------------------------------------------------------------------

require "./spec_helper"

def test_try_multiply(res)
  data = try! res
  data = data * 2
  data
end

def test_unwrap_multiply(value)
  data = unwrap! value
  data = data * 2
  data
end

def test_result_ok(data)
  result! data * 2
end

def test_result_ok_created(data)
  result! data * 2, :created
end

def test_result_err(data)
  result!("".to_i)
end

def test_result_err_input(data)
  result!("".to_i64, err: :input)
end

describe "try!(result)" do
  context "Ok" do
    it "should unwrap the value without blocking the execution of the code" do
      test_try_multiply(Ok.done(2)).should eq 4
    end
  end

  context "Err" do
    it "should block execution of the code and returns a Result error (Err)" do
      res = test_try_multiply(Err.fail("Oops"))
      res.is_a?(Err)
      res.status.should eq :fail
      res.status?(:fail).should be_true
      res.err?.should be_true
      res.value.should eq "Oops"
      res.state[0].should eq :err
      res.state[1].should eq :fail
      res.state.last.should eq "Oops"
      expect_raises(
        Exception,
        "Oops"
      ) do
        res.unwrap
      end
    end
  end
end

describe "unwrap!(value)" do
  context "Ok" do
    it "should unwrap a `Result` without blocking the execution of the code" do
      test_unwrap_multiply(Ok.done(2)).should eq 4
    end

    it "should forward a value without blocking the execution of the code" do
      test_unwrap_multiply(2).should eq 4
    end
  end

  context "Err" do
    it "should raise an error" do
      expect_raises(
        Exception,
        "Oops"
      ) do
        test_unwrap_multiply(Err.fail("Oops"))
      end
    end
  end
end

describe "result!(value, ok, err)" do
  context "Ok" do
    it "should wrap a value into a Result" do
      res = test_result_ok(2)
      res.is_a?(Ok)
      res.status.should eq :done
      res.status?(:done).should be_true
      res.type.should eq :ok
      res.ok?.should be_true
      res.value.should eq 4
      res.unwrap.should eq 4
      res.state[0].should eq :ok
      res.state[1].should eq :done
      res.state.last.should eq 4
    end

    it "should wrap a value into a custom Result" do
      res = test_result_ok_created(2)
      res.is_a?(Ok)
      res.status.should eq :created
      res.status?(:created).should be_true
      res.type.should eq :ok
      res.ok?.should be_true
      res.value.should eq 4
      res.unwrap.should eq 4
      res.state[0].should eq :ok
      res.state[1].should eq :created
      res.state.last.should eq 4
    end
  end

  context "Err" do
    it "should rescue and wrap an exception into a Result" do
      res = test_result_err(2)
      res.is_a?(Err)
      res.status.should eq :fail
      res.status?(:fail).should be_true
      res.type.should eq :err
      res.err?.should be_true
      res.value.should be_a ArgumentError
      res.state[0].should eq :err
      res.state[1].should eq :fail
      res.state.last.should be_a ArgumentError
      expect_raises(
        ArgumentError,
        "Invalid Int32"
      ) do
        res.unwrap
      end
    end

    it "should rescue and wrap an exception into a custom Result" do
      res = test_result_err_input(2)
      res.is_a?(Err)
      res.status.should eq :input
      res.status?(:input).should be_true
      res.type.should eq :err
      res.err?.should be_true
      res.value.should be_a ArgumentError
      res.state[0].should eq :err
      res.state[1].should eq :input
      res.state.last.should be_a ArgumentError
      expect_raises(
        ArgumentError,
        "Invalid Int64"
      ) do
        res.unwrap
      end
    end
  end
end
