defmodule ServerApiUtilsTest do
  use ExUnit.Case

  test "mention to pid conversion" do
    mention = "<0.99.0>"
    assert EngineUtils.mentionToPid(mention) |> :erlang.is_pid == true
  end

  #-----------------------------------------------------------------------------
  # Test extract function with mentions
  test "tests empty string" do
    mention = ""
    assert EngineUtils.excrateFromTweet(mention, 0, "@") == []
  end

  test "tests string with @ in the end" do
    mention = "a@"
    assert EngineUtils.excrateFromTweet(mention, 0, "@") == []
  end

  test "tests only @" do
    mention = "@"
    assert EngineUtils.excrateFromTweet(mention, 0, "@") == []
  end

  test "tests one mention" do
    mention = "tweet sample text with sample @<mention>"
    assert EngineUtils.excrateFromTweet(mention, 0, "@") == ["<mention>"]
  end

  test "tests two complete mentions" do
    mention = "sample text @<mention1> @mention2"
    assert EngineUtils.excrateFromTweet(mention, 0, "@") == ["<mention1>", "mention2"]
  end

  test "tests one incomplete mention" do
    mention = "sample text @mention1 @"
    assert EngineUtils.excrateFromTweet(mention, 0, "@") == ["mention1"]
  end

  #-----------------------------------------------------------------------------
  # Tests for strings containing hashtags

  test "hashtag_test: tests empty string" do
    mention = ""
    assert EngineUtils.excrateFromTweet(mention, 0, "#") == []
  end

  test "tests string with # in the end" do
    mention = "a#"
    assert EngineUtils.excrateFromTweet(mention, 0, "#") == []
  end

  test "tests only #" do
    mention = "#"
    assert EngineUtils.excrateFromTweet(mention, 0, "#") == []
  end

  test "tests one hashtag" do
    mention = "tweet sample text with sample #mention"
    assert EngineUtils.excrateFromTweet(mention, 0, "#") == ["mention"]
  end

  test "tests two complete hashtags" do
    mention = "sample text #mention1 #mention2"
    assert EngineUtils.excrateFromTweet(mention, 0, "#") == ["mention1", "mention2"]
  end

  test "tests one incomplete hashtag" do
    mention = "sample text #mention1 #"
    assert EngineUtils.excrateFromTweet(mention, 0, "#") == ["mention1"]
  end
end
