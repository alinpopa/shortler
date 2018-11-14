defmodule Shortler.Template.ParserTest do
  use ExUnit.Case, async: true
  doctest Shortler
  alias Shortler.Template.Parser

  test "should not parse when giving nil params to inject" do
    assert Parser.parse("this is a <%test%> url", nil) == "this is a <%test%> url"
  end

  test "should not inject params that don't match any dynamic value" do
    assert Parser.parse("this is a <%test%> url", %{"test1" => "value1"}) ==
             "this is a <%test%> url"
  end

  test "should not match invalid dynamic names" do
    assert Parser.parse("this is a <% test%> url", %{"test" => "val1"}) ==
             "this is a <% test%> url"
  end

  test "should successfully replace dynamic names that matches any param" do
    assert Parser.parse("this is a <%test%> url", %{"test" => "val1"}) == "this is a val1 url"
  end

  test "should successfully replace all dynamic names that matches a param" do
    assert Parser.parse("this is a <%test%> and another <%test%> url", %{"test" => "val1"}) ==
             "this is a val1 and another val1 url"
  end

  test "should ignore params when no dynamic names" do
    assert Parser.parse("this is a test", %{"test" => "val1"}) == "this is a test"
  end

  test "should parse and replace all dynamic names from an url" do
    assert Parser.parse("http://www.google.com/<%p0%>/2/4/<%p1%>", %{"p0" => "abc"}) ==
             "http://www.google.com/abc/2/4/<%p1%>"
  end
end
