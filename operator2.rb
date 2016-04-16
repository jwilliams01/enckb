
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

class LiteralOperator < Operator
  def self.evaluate(literal)
    value = literal
  end
end

class VariableOperator < Operator
  def self.evaluate(variable)
    value = ($variables.key? variable) ? $variables[variable] : nil
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
    variable = args['variable']
    value = args['value']
    $variables[variable] = value
    puts "Set: #{variable} = #{value}"
    value
  end
end

class StartsWithOperator < Operator
end

class EndsWithOperator < Operator
  def self.evaluate(args)
    value = nil
    targetValue = nil
    args['target'].each_pair { |op, ar| targetValue = self.evaluateExpr(op, ar) }
    if targetValue != nil
      value = false
      args['values'].each do |v|
        v.each_pair do |op, ar| 
          matchValue = self.evaluateExpr(op, ar)
          value |= targetValue.end_with?(matchValue)
        end
      end
    end
    value
  end
end

class MatchesOperator < Operator
end

$operators = {
  "literal" => LiteralOperator,
  "variable" => VariableOperator,
  "expr" => ExprOperator,
  "set" => SetOperator,
  "startsWith" => StartsWithOperator,
  "endsWith" => EndsWithOperator,
  "matches" => MatchesOperator,
}
