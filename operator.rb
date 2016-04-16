
$operators = Hash.new

class Operator 
  def self.evaluate(args)
    value = nil
  end

  def self.evaluateExpr(oper, args)
    value = nil

    if $operators.key? oper
      value = $operators[oper].evaluate(args)
    else
      puts "ERROR: Unsupported operation #{oper}"
    end

    value
  end
end

class ExprOperator < Operator

  def self.evaluate(args)
    value = nil
    case args['entity']
    when 'variable'
      value = ($variables.key? args['name']) ? $variables[args['name']] : nil
    when 'literal'
      value = args['value']
    end
    value
  end

end

class SetOperator < Operator
  def self.evaluate(args)
    value = nil
    value
  end
end

class StartsWithOperator < Operator
end

class EndsWithOperator < Operator
  def self.evaluate(args)
    value = nil

    value
  end
end

class MatchesOperator < Operator
end

$operators = {
  "expr" => ExprOperator,
  "set" => SetOperator,
  "startsWith" => StartsWithOperator,
  "endsWith" => EndsWithOperator,
  "matches" => MatchesOperator,
}
