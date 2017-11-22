defmodule ServerApiTest do
  use ExUnit.Case
  doctest ServerApi

  test "tests getmention: empty string" do
    mention = ""
    assert ServerApi.getMentions(mention, 0) == []
  end

  test "tests getmention string with @ in the end" do
    mention = "a@"
    assert ServerApi.getMentions(mention, 0) == []
  end

  test "tests getmention: only @" do
    mention = "@"
    assert ServerApi.getMentions(mention, 0) == []
  end

  test "tests getmention: one mention" do
    mention = "tweet sample text with sample @mention"
    assert ServerApi.getMentions(mention, 0) == ["mention"]
  end

  test "tests getmention: two complete mentions" do
    mention = "sample text @mention1 @mention2"
    assert ServerApi.getMentions(mention, 0) == ["mention1", "mention2"]
  end

  test "tests getmention: one incomplete mention" do
    mention = "sample text @mention1 @"
    assert ServerApi.getMentions(mention, 0) == ["mention1"]
  end
end
