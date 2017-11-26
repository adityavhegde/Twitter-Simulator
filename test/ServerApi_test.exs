defmodule ServerApiUtilsTest do
  use ExUnit.Case
  test "tests empty string" do
    mention = ""
    assert ServerApiUtils.excrateFromTweet(mention, 0, "@") == []
  end

  test "tests string with @ in the end" do
    mention = "a@"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "@") == []
  end

  test "tests only @" do
    mention = "@"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "@") == []
  end

  test "tests one mention" do
    mention = "tweet sample text with sample @<mention>"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "@") == ["<mention>"]
  end

  test "tests two complete mentions" do
    mention = "sample text @<mention1> @mention2"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "@") == ["<mention1>", "mention2"]
  end

  test "tests one incomplete mention" do
    mention = "sample text @mention1 @"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "@") == ["mention1"]
  end

  #-----------------------------------------------------------------------------
  # Tests for strings containing hashtags

  test "hashtag_test: tests empty string" do
    mention = ""
    assert ServerApiUtils.excrateFromTweet(mention, 0, "#") == []
  end

  test "tests string with # in the end" do
    mention = "a#"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "#") == []
  end

  test "tests only #" do
    mention = "#"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "#") == []
  end

  test "tests one hashtag" do
    mention = "tweet sample text with sample #mention"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "#") == ["mention"]
  end

  test "tests two complete hashtags" do
    mention = "sample text #mention1 #mention2"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "#") == ["mention1", "mention2"]
  end

  test "tests one incomplete hashtag" do
    mention = "sample text #mention1 #"
    assert ServerApiUtils.excrateFromTweet(mention, 0, "#") == ["mention1"]
  end
end
