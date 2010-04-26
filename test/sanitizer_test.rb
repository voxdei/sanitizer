require 'test_helper'

class Bot
  
  def name
    "My name is BOT"
  end
  
end

class SanitizerTest < ActiveSupport::TestCase
  
  def setup
    @bot = Bot.new
    @bot.remove_sanitized_methods
  end
  
  test "removing all the add methods" do
    Bot.sanitize_the :name, /BOT/
    Bot.sanitize_the :name2, //
    Bot.sanitize_the :name3, //
    
    assert @bot.respond_to?("sanitized_name")
    assert @bot.respond_to?("sanitized_name2")
    assert @bot.respond_to?("sanitized_name3")
    
    @bot.remove_sanitized_methods
    
    assert !@bot.respond_to?("sanitized_name")  
    assert !@bot.respond_to?("sanitized_name2")  
    assert !@bot.respond_to?("sanitized_name3")  
  end
  
  test "replacing overrided methods by former methods" do
    assert_equal @bot.name, "My name is BOT"
    Bot.sanitize_the :name, /BOT/, :override => true
    assert !@bot.respond_to?("sanitized_name")
    
    # method is now ovverrided, behaviour should have changed
    assert_equal @bot.name, "My name is "
    
    # we restore it back to its former state
    @bot.remove_sanitized_methods
    assert_equal @bot.name, "My name is BOT"
  end
  
  test "that all objects should respond to the sanitize's methods" do
    assert Bot.singleton_methods.include?("sanitize_this")
    assert Bot.singleton_methods.include?("sanitize_my")
    assert Bot.singleton_methods.include?("sanitize_the")
  end
  
  test "sanitizing Bot's name should add a new method" do
    # calling the module
    Bot.sanitize_the :name, /BOT/ # this will remove BOT
    assert @bot.respond_to?("sanitized_name")
    
    assert_equal @bot.name, "My name is BOT"
    assert_equal @bot.sanitized_name, "My name is "
    
    # changing the regex
    Bot.sanitize_my :name, /name/
    assert_equal @bot.sanitized_name, "My  is BOT"
    
    # changing the regex
    Bot.sanitize_this :name, /name | BOT/
    assert_equal @bot.sanitized_name, "My is"
  end
  
  test "we can substitute the match instead of removing it" do
    Bot.sanitize_this :name, /BOT/, :substitution => "Ultimate BOT"
    assert_equal @bot.sanitized_name, "My name is Ultimate BOT"
  end
  
  test "sanitizing Bot should replace the original method" do
    assert_equal @bot.name, "My name is BOT"
    Bot.sanitize_the :name, /My name is BOT/, :substitution => "I have no more name", :override => true
    assert_equal @bot.name, "I have no more name"
  end
  
  test "chaining overriding then coming back to former state should work" do
    assert_equal @bot.name, "My name is BOT"
    Bot.sanitize_the :name, /My name is BOT/, :substitution => "I have no more name", :override => true
    assert_equal @bot.name, "I have no more name"
    
    # we chain the process
    Bot.sanitize_the :name, /I have no more name/, :substitution => "Changed again ?", :override => true
    assert_equal @bot.name, "My name is BOT" # we are overriding the former method, so the current name method returns "My name is BOT"
    
    # back to origin
    @bot.remove_sanitized_methods
    assert_equal @bot.name, "My name is BOT"
  end
  
end
