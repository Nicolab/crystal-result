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

  describe "Ok" do
    it "Ok" do
      Ok.type.should eq :ok
      Ok.ok?.should be_true
      Ok.err?.should be_false
    end

    it "Ok[]" do
      res = Ok[2]
      res.is_a?(Ok).should be_true
      res.is_a?(Ok::Done).should be_true
      res.is_a?(OkType::Done).should be_true
      test_ok res, 2
    end

    {% for type in ok_types %}
    it "Ok.{{type.underscore.id}}" do
      res = Ok.{{type.underscore.id}}(2)
      res.is_a?(Ok).should be_true
      res.is_a?(Ok::{{type.id}}).should be_true
      res.is_a?(OkType::{{type.id}}).should be_true
      test_ok res, 2
    end

    it "Ok::{{type.id}}" do
      res = Ok::{{type.id}}.new(2)
      res.is_a?(Ok).should be_true
      res.is_a?(Ok::{{type.id}}).should be_true
      res.is_a?(OkType::{{type.id}}).should be_true
      test_ok res, 2
    end

    it "OkType::{{type.id}}" do
      res = OkType::{{type.id}}.new(2)
      res.is_a?(Ok).should be_true
      res.is_a?(Ok::{{type.id}}).should be_true
      res.is_a?(OkType::{{type.id}}).should be_true
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
      res.is_a?(Err::Fail).should be_true
      res.is_a?(ErrType::Fail).should be_true
      test_err res, "Oops"

      exception = Exception.new "Oops"
      res = Err[exception]
      res.is_a?(Err).should be_true
      res.is_a?(Err::Fail).should be_true
      res.is_a?(ErrType::Fail).should be_true
      test_err res, exception
    end

    {% for type in err_types %}
    it "Err.{{type.underscore.id}}" do
      res = Err.{{type.underscore.id}}("Oops")
      res.is_a?(Err).should be_true
      res.is_a?(Err::{{type.id}}).should be_true
      res.is_a?(ErrType::{{type.id}}).should be_true
      test_err res, "Oops"

      exception = Exception.new "Oops"
      res = Err.{{type.underscore.id}}(exception)
      res.is_a?(Err).should be_true
      res.is_a?(Err::{{type.id}}).should be_true
      res.is_a?(ErrType::{{type.id}}).should be_true
      test_err res, exception
    end

    it "Err::{{type.id}}" do
      res = Err::{{type.id}}.new("Oops")
      res.is_a?(Err).should be_true
      res.is_a?(Err::{{type.id}}).should be_true
      res.is_a?(ErrType::{{type.id}}).should be_true
      test_err res, "Oops"

      exception = Exception.new "Oops"
      res = Err::{{type.id}}.new(exception)
      res.is_a?(Err).should be_true
      res.is_a?(Err::{{type.id}}).should be_true
      res.is_a?(ErrType::{{type.id}}).should be_true
      test_err res, exception
    end

    it "ErrType::{{type.id}}" do
      res = ErrType::{{type.id}}.new("Oops")
      res.is_a?(Err).should be_true
      res.is_a?(Err::{{type.id}}).should be_true
      res.is_a?(ErrType::{{type.id}}).should be_true
      test_err res, "Oops"

      exception = Exception.new "Oops"
      res = ErrType::{{type.id}}.new(exception)
      res.is_a?(Err).should be_true
      res.is_a?(Err::{{type.id}}).should be_true
      res.is_a?(ErrType::{{type.id}}).should be_true
      test_err res, exception
    end
    {% end %}
  end

  {% end %}
end
