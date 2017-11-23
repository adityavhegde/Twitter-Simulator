defmodule ServerApiUtilsTest do
  use ExUnit.Case
  test "tests getmention: empty string" do
    mention = ""
    assert ServerApiUtils.getMentions(mention, 0) == []
  end

  test "tests getmention string with @ in the end" do
    mention = "a@"
    assert ServerApiUtils.getMentions(mention, 0) == []
  end

  test "tests getmention: only @" do
    mention = "@"
    assert ServerApiUtils.getMentions(mention, 0) == []
  end

  test "tests getmention: one mention" do
    mention = "tweet sample text with sample @mention"
    assert ServerApiUtils.getMentions(mention, 0) == ["mention"]
  end

  test "tests getmention: two complete mentions" do
    mention = "sample text @mention1 @mention2"
    assert ServerApiUtils.getMentions(mention, 0) == ["mention1", "mention2"]
  end

  test "tests getmention: one incomplete mention" do
    mention = "sample text @mention1 @"
    assert ServerApiUtils.getMentions(mention, 0) == ["mention1"]
  end
end
