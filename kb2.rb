#!/usr/bin/ruby

require 'pp'
require './operator2'

$variables = Hash.new

rules = [
  {
    "ruleName" => "declarations",
    "trigger" => { "literal" => true },
    "answers" => [
      {"declare" => ["fqdn", "site", "found", "host", "undefined"]}
    ]
  },
  {
    "ruleName" => "toque",
    "trigger" => { "literal" => true },
    "answers" => [
      {"set" => { "variable" => "fqdn", "value" => "toque.atl-williams.publicvm.com" }}
    ]
  },
  {
    "ruleName" => "endsWith test 1",
    "trigger" => {
      "endsWith" => { "target" => { "variable" => "fqdn" }, "values" => [ {"literal" => ".atl-williams.publicvm.com"} ] }
    },
    "answers" => [
      {"set" => { "variable" => "site", "value" => "publicvm" }},
      {"set" => { "variable" => "found", "value" => true}},
    ]
  },
  {
    "ruleName" => "endsWith test 2",
    "trigger" => {
      "endsWith" => { "target" => { "variable" => "fqdn" }, "values" => [ {"literal" => ".atl-williams.googlum.com"} ] }
    },
    "answers" => [
      {"set" => { "variable" => "site", "value" => "googlum" }},
      {"set" => { "variable" => "found", "value" => true}},
    ]
  },
  {
    "ruleName" => "startWith test 1",
    "trigger" => {
      "startsWith" => { "target" => { "variable" => "fqdn" }, "values" => [ {"literal" => "toque."} ] }
    },
    "answers" => [
      {"set" => { "variable" => "host", "value" => "toque" }},
    ]
  },
  {
    "ruleName" => "startWith test 2",
    "trigger" => {
      "startsWith" => { "target" => { "variable" => "fqdn" }, "values" => [ {"literal" => "www."} ] }
    },
    "answers" => [
      {"set" => { "variable" => "host", "value" => "www" }},
    ]
  },
]

class Rule

  def self.evaluateTrigger(rule)
    results = []

    rule['trigger'].each_pair do |oper, args|
      puts "Evaluating #{oper}"
      results.push Operator::evaluateExpr(oper, args)
    end
    
    result = true
    results.each do |r|
      case r.class.to_s
      when "NilClass"
        result = false
      when "String"
        result &&= true
      when "Integer"
        result &&= (r != 0)
      when "TrueClass"
        result &&= true
      when "FalseClass"
        result &&= false
      else
        result &&= r
      end
    end

    result
  end

  def self.evaluateAnswers(rule)
    i = 1
    rule["answers"].each do |answer|
      print "... #{i}: "
      pp answer
      answer.each_pair { |oper, args| Operator::evaluateExpr(oper, args) }
      i += 1
    end
  end
end

puts "=== Evaluation ==="
rules.each do |rule|
  rule['fired'] = 'not fired'
  
  puts "--- Evaluating rule \"#{rule['ruleName']}\" --------------------"

  print "... trigger: "
  if Rule::evaluateTrigger(rule)
    rule['fired'] = 'fired'
    puts "... rule triggered, evaluating answers."
    Rule::evaluateAnswers(rule)
  else
    puts "... rule not triggered."
  end
  puts
end

puts "=== Variables ==="
$variables.each_pair do |name, value| 
  if value != nil
    puts "%s = %s" % [name, value]
  else
    puts "%s undefined" % name
  end
end

puts "\n=== Rules Fired ==="
rules.each { |rule| puts "#{rule['ruleName']}" if rule['fired'] == 'fired' }

puts "\n=== Rules Not Fired ==="
rules.each { |rule| puts "#{rule['ruleName']}" if rule['fired'] == 'not fired' }
