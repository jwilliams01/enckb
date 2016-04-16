#!/usr/bin/ruby

require 'pp'
require './operator2'

$variables = Hash.new
$variables["dummy"] = nil
$variables["stupid"] = 43

rules = [
  {
    "ruleName" => "toque",
    "trigger" => {
      "literal" => true
    },
    "answers" => [
      {"set" => { "variable" => "fqdn", "value" => "toque.atl-williams.publicvm.com" }}
    ]
  },
  {
    "ruleName" => "jeff home domain",
    "trigger" => {
      "endsWith" => {
        "target" => {
          "variable" => "fqdn"
        },
        "values" => [
          {"literal" => ".atl-williams.publicvm.com"}
        ]
      }
    },
    "answers" => [
      {"set" => { "variable" => "site", "value" => "atl-williams" }}
    ]
  }
]

class Rule

  def self.evaluateTrigger(rule)
    results = []
    rule['trigger'].each_pair do |oper, args|
      puts "Evaluating #{oper}"
      results.push Operator::evaluateExpr(oper, args)
    end
    
    pp results

    result = true
    results.each do |r|
      case r.class
      when NilClass
        result = false
      when String
        result &= true
      when Integer
        result &= (r != 0)
      default
        result &= r
      end
    end
    result

  end

  def self.evaluateAnswers(rule)
    i = 1
    rule["answers"].each do |answer|
      puts "(answer #{i})"
      pp answer
      answer.each_pair { |oper, args| Operator::evaluateExpr(oper, args) }
      i += 1
    end
  end
end

puts "=== Evaluation ==="
rules.each do |rule|
  
  puts "--- Evaluating rule #{rule['ruleName']}"
  pp rule

  puts "--- 1 --- Evaluating trigger"
  if Rule::evaluateTrigger(rule)
    puts "--- Rule triggered: #{rule['ruleName']}"
    puts "--- 2 --- Evaluating answers"

    Rule::evaluateAnswers(rule)
  end
end

puts "=== Variables ==="
$variables.each_pair do |name, value| 
  if value != nil
    puts "%s=%s" % [name, value]
  else
    puts "%s undefined" % name
  end
end
