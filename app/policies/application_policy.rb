class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user&.treasurer? || user&.main_bartender? || user&.secretary?
  end

  def show?
    scope.exists?(id: record.id) && index?
  end

  def create?
    user&.treasurer?
  end

  def new?
    create?
  end

  def update?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    user&.treasurer? || user&.main_bartender? || user&.secretary?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
