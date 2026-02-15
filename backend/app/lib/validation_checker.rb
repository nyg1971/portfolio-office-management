# frozen_string_literal: true

class ValidationChecker
  def run_consistency_check
    EnumConsistencyChecker.new.run
  end

  def run_yaml_syntax_check
    YamlSyntaxChecker.new.run
  end
end
