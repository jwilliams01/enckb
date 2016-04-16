#!/usr/bin/ruby

require 'pp'
require './operator'

$variables = Hash.new
$variables["dummy"] = nil
$variables["stupid"] = 43

rules = [
  {
    "ruleName" => "toque",
    "trigger" => {
      "expr" => { "entity" => "literal", "value" => true }
    },
    "answers" => [
      {"set" => { "name" => "fqdn", "value" => "toque.atl-williams.publicvm.com" }}
    ]
  },
  {
    "ruleName" => "jeff home domain",
    "trigger" => {
      "endsWith" => {
        "target" => {
          "expr" => { "entity" => "variable", "name" => "fqdn" }
        },
        "values" => [
          "expr" => { "entity" => "literal", "value" => ".atl-williams.publicvm.com" }
        ]
      }
    },
    "answers" => [
      {"set" => { "name" => "site", "value" => "atl-williams" }}
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
end

puts "=== Rules ==="
pp rules

puts "=== Evaluation ==="
rules.each do |rule|
  
  puts "--- Evaluating rule #{rule['ruleName']}"
  pp rule

  if Rule::evaluateTrigger(rule)
    puts "--- Rule triggered: #{rule['ruleName']}"
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
