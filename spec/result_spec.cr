# This file is part of "result".
#
# This source code is licensed under the MIT license, please view the LICENSE
# file distributed with this source code. For the full
# information and documentation: https://github.com/Nicolab/crystal-result
# ------------------------------------------------------------------------------

require "./spec_helper"

describe Result do
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

  describe "Ok" do
    it "Ok" do
      Ok.type.should eq :ok
      Ok.ok?.should be_true
      Ok.err?.should be_false
    end

    it "Ok[]" do
      res = Ok[2]
      res.is_a?(Ok).should be_true
      res.status.should eq :done
      res.status?(:done).should be_true
      test_ok res, 2
    end

    {% for type in ok_types %}
    it "Ok.{{type.id}}" do
      res = Ok.{{type.id}}(2)
      res.is_a?(Ok).should be_true
      res.status.should eq :{{type.id}}
      res.status?(:{{type.id}}).should be_true
      test_ok res, 2
    end

    it "Ok.new :{{type.id}}" do
      res = Ok.new(:{{type.id}}, 2)
      res.is_a?(Ok).should be_true
      res.status.should eq :{{type.id}}
      res.status?(:{{type.id}}).should be_true
      test_ok res, 2
    end
    {% end %}
  end

  describe "Err" do
    it "Err" do
      Err.type.should eq :err
      Err.ok?.should be_false
      Err.err?.should be_true
    end

    it "Err[]" do
      res = Err["Oops"]
      res.is_a?(Err).should be_true
      res.status.should eq :fail
      res.status?(:fail).should be_true
      test_err res, "Oops"

      exception = Exception.new "Oops"
      res = Err[exception]
      res.is_a?(Err).should be_true
      res.status.should eq :fail
      res.status?(:fail).should be_true
      test_err res, exception
    end

    {% for type in err_types %}
    it "Err.{{type.id}}" do
      res = Err.{{type.id}}("Oops")
      res.is_a?(Err).should be_true
      res.status.should eq :{{type.id}}
      res.status?(:{{type.id}}).should be_true
      test_err res, "Oops"

      exception = Exception.new "Oops"
      res = Err.{{type.id}}(exception)
      res.is_a?(Err).should be_true
      res.status.should eq :{{type.id}}
      res.status?(:{{type.id}}).should be_true
      test_err res, exception
    end

    it "Err.new :{{type.id}}" do
      res = Err.new(:{{type.id}}, "Oops")
      res.is_a?(Err).should be_true
      res.status.should eq :{{type.id}}
      res.status?(:{{type.id}}).should be_true
      test_err res, "Oops"

      exception = Exception.new "Oops"
      res = Err.new(:{{type.id}}, exception)
      res.is_a?(Err).should be_true
      res.status.should eq :{{type.id}}
      res.status?(:{{type.id}}).should be_true
      test_err res, exception
    end
    {% end %}
  end
  {% end %}
end
