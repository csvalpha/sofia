module Debit
  class TransactionPolicy < ApplicationPolicy
    def index?
      user&.treasurer? || user.present?
    end

    def show?
      user&.treasurer? || record.user == user
    end

    def create?
      user&.treasurer?
    end

    def update?
      user&.treasurer?
    end

    def destroy?
      user&.treasurer?
    end

    class Scope < Scope
      def resolve
        if user&.treasurer?
          scope.all
        elsif user.present?
          scope.where(user: user)
        else
          scope.none
        end
      end
    end
  end
end
