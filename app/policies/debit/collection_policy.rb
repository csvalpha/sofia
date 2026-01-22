module Debit
  class CollectionPolicy < ApplicationPolicy
    def index?
      user&.treasurer?
    end

    def show?
      user&.treasurer? || record.transactions.exists?(user: user)
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

    def generate?
      user&.treasurer?
    end

    def download?
      user&.treasurer?
    end

    class Scope < Scope
      def resolve
        if user&.treasurer?
          scope.all
        elsif user.present?
          scope.for_user(user)
        else
          scope.none
        end
      end
    end
  end
end
