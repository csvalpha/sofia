# Automatic Mollie Charge Feature - Implementation Guide

## Overview
This feature enables Sofia users to set up automatic SEPA mandates with Mollie and enable automatic charging when their saldo (balance) drops below 0 euros.

## Feature Flow

### 1. Mandate Setup
- User navigates to their profile page (users/show.html.erb)
- User clicks "Mandate instellen" button
- System creates/retrieves Mollie customer
- User is redirected to Mollie checkout for 1 cent payment
- Payment includes `sequenceType: 'first'` to establish mandate
- Upon successful payment, mandate ID is stored in user record

### 2. Enable Auto-Charge
- User can toggle auto-charge using a checkbox on their profile
- Requires valid mandate before enabling
- Stores preference in `users.auto_charge_enabled` column

### 3. Automatic Charging (Daily Job)
- AutoChargeJob runs daily at 3 AM (configurable in sidekiq.yml)
- For each user with auto_charge_enabled and valid mandate:
  - Check if credit is negative
  - Calculate amount needed (balance + 1 euro buffer)
  - Cap at 50 euros max to prevent accidental large charges
  - Create recurring SEPA payment via Mollie
  - Store payment record in database

## Database Schema

### Migration: AddMollieM andateToUsers
Location: `db/migrate/20251207012900_add_mollie_mandate_to_users.rb`

```ruby
add_column :users, :mollie_customer_id, :string
add_column :users, :mollie_mandate_id, :string
add_column :users, :auto_charge_enabled, :boolean, default: false, null: false

add_index :users, :mollie_customer_id, unique: true
add_index :users, :mollie_mandate_id, unique: true
```

## Models

### User Model (`app/models/user.rb`)
Added methods:
- `mollie_customer` - Retrieves Mollie customer object
- `mollie_mandate` - Retrieves Mollie mandate object
- `mandate_valid?` - Checks if mandate status is 'valid'
- `auto_charge_available?` - Checks if auto-charge is enabled and mandate is valid

### Payment Model (`app/models/payment.rb`)
Updated methods:
- `create_with_mollie` - Now supports `first_payment: true` for mandate setup
  - Sets `sequenceType: 'first'` for mandate establishment
  - Redirects to `mandate_callback` after payment
- `process_complete_payment!` - Skips credit mutation for 0.01 EUR payments
- `user_amount` - Now allows 0.01 EUR for mandate setup payments

## Controllers

### PaymentsController (`app/controllers/payments_controller.rb`)
New actions:

#### `setup_mandate`
- Creates/retrieves Mollie customer from user data
- Creates 1-cent payment with mandate sequence
- Redirects to Mollie checkout
- POST `/payments/setup_mandate`

#### `mandate_callback`
- Handles Mollie redirect after 1-cent mandate payment
- Extracts mandate_id from payment
- Stores mandate_id in user record
- GET `/payments/:id/mandate_callback`

#### `toggle_auto_charge`
- Toggles user's auto_charge_enabled flag
- Requires valid mandate before enabling
- POST `/payments/toggle_auto_charge`

## Views

### Users Show Page (`app/views/users/show.html.erb`)
New tab "Automatische opwaardering" includes:
- Explanation of auto-charge feature
- Conditional UI states:
  - No mandate: Shows "Mandate instellen" button
  - Valid mandate: Shows toggle checkbox for auto-charge
  - Invalid mandate: Shows "Mandate opnieuw instellen" button
- Only visible to current user (not other users)

## Jobs

### AutoChargeJob (`app/jobs/auto_charge_job.rb`)
Runs daily at 3 AM (configurable via sidekiq.yml)

Logic:
1. Find all users with `auto_charge_enabled: true`
2. Filter by valid mandate
3. Filter by negative credit
4. For each user:
   - Calculate amount needed (|credit| + 1 euro buffer)
   - Cap at 50 euros
   - Create recurring SEPA payment via Mollie API
   - Store payment record in database
   - If payment immediately paid, update status

Error handling:
- Catches `Mollie::ResponseError`
- Logs errors but continues processing other users
- Reports health check to monitoring

## Authorization

### PaymentPolicy (`app/policies/payment_policy.rb`)
New policy methods:
- `setup_mandate?` - User must be authenticated and Mollie enabled
- `mandate_callback?` - User must be authenticated and Mollie enabled
- `toggle_auto_charge?` - User must be authenticated and Mollie enabled

## Routes

Updated: `config/routes.rb`

```ruby
resources :payments, only: %i[index create] do
  member do
    get :callback
    get :mandate_callback
  end
  collection do
    get :add
    post :setup_mandate
    post :toggle_auto_charge
  end
end
```

New routes:
- POST `/payments/setup_mandate` - Initiate mandate setup
- POST `/payments/toggle_auto_charge` - Toggle auto-charge
- GET `/payments/:id/mandate_callback` - Mandate payment callback

## Mollie API Integration

### Mollie Documentation References
- [Create Customer](https://docs.mollie.com/reference/create-customer)
- [Create Payment](https://docs.mollie.com/reference/create-payment)
- [Create Mandate](https://docs.mollie.com/reference/create-mandate)
- [Recurring Payments](https://docs.mollie.com/payments/recurring)
- [Status Changes](https://docs.mollie.com/payments/status-changes)

### Payment Sequence Types
- `first`: Establishes a mandate (1-cent payment)
- `recurring`: Uses existing mandate for SEPA charge

### Mandate Status
- `valid`: Mandate is active and can be used
- Other statuses: `pending`, `invalid`, `expired`

## Configuration

### Sidekiq Scheduler (`config/sidekiq.yml`)
```yaml
AutoChargeJob:
  cron: '0 3 * * *' # Every day at 3 AM
```

Change the cron expression as needed. See https://crontab.guru for help.

## Security Considerations

1. **Mandate Validation**: Only valid mandates can trigger charges
2. **Amount Limits**: Max 50 euro charge to prevent accidental large transactions
3. **User Control**: Users must explicitly enable auto-charge
4. **Authorization**: Only authenticated users can set up mandates
5. **Data Privacy**: Mandate IDs are securely stored and associated with customers

## Testing Recommendations

1. **Unit Tests for User Model**
   - Test `mollie_mandate`, `mandate_valid?`, `auto_charge_available?`

2. **Integration Tests for PaymentsController**
   - Test setup_mandate flow
   - Test mandate_callback processing
   - Test toggle_auto_charge authorization

3. **Job Tests for AutoChargeJob**
   - Mock Mollie API calls
   - Test charge calculation logic
   - Test error handling

4. **View Tests**
   - Test visibility of auto-charge tab
   - Test UI state changes based on mandate status

## Development Notes

### Required Gems
Already installed:
- `mollie-api-ruby` (~> 4.18.0)

### Environment Variables
- `mollie_api_key` - Must be set in credentials.yml.enc

### Monitoring
- AutoChargeJob reports health check to monitoring system
- All Mollie API errors are logged with user context
- Payment polling job continues to track mandate payment status

## Deployment Steps

1. Run migration: `rails db:migrate`
2. Deploy code
3. Restart Sidekiq workers to pick up new job schedule
4. Monitor logs for AutoChargeJob execution

## Future Enhancements

1. Add admin dashboard to view mandate statuses
2. Send email notifications on auto-charge attempts
3. Add retry logic for failed recurring payments
4. Implement minimum balance configuration per user
5. Add charge history reporting for users
6. Support for alternative payment methods (ACH, etc.)
