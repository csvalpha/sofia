# AI Dev Guide - SOFIA

## Env
Rails 7.2.3, Ruby 3.3
Container: development-environment-alpha-1 (same as AMBER)
Path in container: Check with pwd
Port: 5000
Node: Yes (yarn, webpack)
DB: PostgreSQL 14.7
Redis: 6.2-alpine

Run: `docker-compose up -d` then access at http://localhost:5000
CMD: `docker exec -it development-environment-alpha-1 /bin/bash -l -c "cd ~/sofia && bundle exec <cmd>"`
Direct: Enter container, `cd ~/sofia`, then run `bundle exec <cmd>`

## Rules
1. Follow existing patterns
2. Tests for everything (coverage commented in spec_helper but aim high)
3. Follow RuboCop or document exception with reason
4. Keep it simple: convention over configuration
5. Don't add gems unless real benefit (student-maintained)

## RuboCop
Config: `.rubocop.yml`
Target: Rails 7.2, Ruby 3.3, NewCops: enable
LineLength: Max 140
Disabled: HttpPositionalArguments, I18nLocaleTexts, ReversibleMigration, Documentation, FrozenStringLiteralComment, Naming/MemoizedInstanceVariableName, Naming/PredicateMethod, RSpec/SpecFilePathFormat
Modified: RSpec/NestedGroups Max:4, RSpec/MultipleExpectations Max:5, RSpec/MultipleMemoizedHelpers disabled, Style/ClassAndModuleChildren excludes controllers/v1/**/*
Exceptions: Must explain why in .rubocop.yml comments

## Structure
Controllers: `app/controllers/*.rb` extend ApplicationController
Models: `app/models/*.rb`
Jobs: `app/jobs/*.rb`
Policies: `app/policies/*.rb` (Pundit)
Views: ERB templates
Tests: `spec/controllers/*_spec.rb`, `spec/models/*_spec.rb`
Factories: `spec/factories/*.rb` use FactoryBot + Faker

## Controller Pattern
```ruby
class ControllerNameController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:public_action]
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Model
    @items = policy_scope(Model.includes(...).order(...).page(params[:page]))
  end

  def show
    @item = Model.find(params[:id])
    authorize @item
  end

  def create
    @item = Model.new(item_params.merge(user: current_user))
    authorize @item
    if @item.save
      flash[:success] = 'Created'
      redirect_to ...
    else
      flash[:error] = @item.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def item_params
    params.require(:item).permit(policy(Model.new).permitted_attributes)
  end
end
```

## Policy Pattern
```ruby
class ModelPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present? && user.role?(:role_name)
  end

  def update?
    user.present? && (record.user == user || user.role?(:admin))
  end

  def destroy?
    update?
  end

  class Scope < Scope
    def resolve
      if user.role?(:admin)
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
```

## Test Pattern (Controller)
```ruby
require 'rails_helper'

describe ControllerNameController do
  describe 'GET index' do
    let(:user) { create(:user, :role) }

    it 'unauthenticated without permission' do
      sign_in create(:user)
      get :index
      expect(response.status).to eq 403
    end

    context 'with permission' do
      before { sign_in user }

      it 'returns success' do
        get :index
        expect(response.status).to eq 200
      end
    end
  end
end
```

## Factory Pattern
```ruby
FactoryBot.define do
  factory :model do
    name { Faker::Type.method }
    user

    trait :role_name do
      after :create do |model, _evaluator|
        model.roles = [create(:role, role_type: :role_name)]
      end
    end
  end
end
```

## Test What
Controllers: auth, Pundit policies, response codes (200, 302, 403), flash messages, redirects, renders, enqueued jobs
Models: validations, associations, scopes, methods, callbacks, state machines
Policies: all permission methods, scopes
Jobs: queuing, execution, error handling
Requests: API endpoints, response codes, JSON structure

## Devise
Authentication: Devise with OmniAuth (amber_oauth2, identity)
User model: has roles through roles_users join table
Role traits: :treasurer, :main_bartender, :renting_manager
Helper: `sign_in user` in specs

## Background Jobs
Sidekiq with Redis
Scheduler: sidekiq-scheduler for cron-like jobs
Job pattern: `AppJob.perform_later(args)` or `AppJob.perform_now(args)`

## Commands
Test all: `bundle exec rspec`
Test file: `bundle exec rspec spec/path/to/file_spec.rb`
RuboCop: `bundle exec rubocop`
RuboCop fix: `bundle exec rubocop -a`
Guard: `bundle exec guard`
DB: `bundle exec rails db:migrate`, `bundle exec rails g migration Name`
Console: `bundle exec rails console`
Sidekiq: `bundle exec sidekiq -C config/sidekiq.yml`
Assets: `yarn build:css`, `yarn watch`

## Docker Commands
Enter: `docker exec -it development-environment-alpha-1 /bin/bash -l` then `cd ~/sofia`
Run cmd: `docker exec -it development-environment-alpha-1 /bin/bash -l -c "cd ~/sofia && bundle exec rspec"`

## Key Gems
Devise, Pundit, Sidekiq, PaperTrail, Paranoia, Mollie API, OmniAuth, Turbo Rails

## Pitfalls
- Don't use `docker exec ... bundle exec ...` directly (PATH + working dir issues)
- Don't skip tests
- Don't ignore RuboCop
- Use `policy(Model).permitted_attributes` for strong params
- Use `authorize @model` in controllers
- Use Pundit scopes: `policy_scope(Model)`
- Keep controllers thin, move logic to models/services
- Don't duplicate permission logic, use Pundit policies
