# frozen_string_literal: true

# Engine to evaluate a set of configurable rules.
module Laminar
  module Flow
    # Collection of rule branches and their conditions.
    class BranchList < Array
      # Returns the first branch that satisfies its branch condition.
      def first_applicable(target)
        each do |branch|
          return branch if branch.meets_condition?(target)
        end
        nil
      end
    end
  end
end
