# Quick Start: Automatic Mollie Charge Feature

## What Was Built

A complete feature that allows Sofia users to:
1. Set up a SEPA mandate with Mollie by paying 1 cent
2. Enable automatic charging when their balance goes below 0 euros
3. Manage their auto-charge settings from their profile page

## Files Created/Modified

### New Files
1. **db/migrate/20251207012900_add_mollie_mandate_to_users.rb**
   - Adds mandate storage columns to users table

2. **app/jobs/auto_charge_job.rb**
   - Daily job that charges users with negative balance

3. **FEATURE_AUTO_CHARGE.md**
   - Comprehensive implementation documentation

### Modified Files
1. **app/models/user.rb**
   - Added mandate management methods

2. **app/models/payment.rb**
   - Added support for 1-cent mandate setup payments

3. **app/controllers/payments_controller.rb**
   - Added setup_mandate, mandate_callback, toggle_auto_charge actions

4. **app/views/users/show.html.erb**
   - Added auto-charge UI tab with mandate management

5. **app/policies/payment_policy.rb**
   - Added authorization for new mandate actions

6. **config/routes.rb**
   - Added new payment routes

7. **config/sidekiq.yml**
   - Added AutoChargeJob schedule (daily at 3 AM)

## To Deploy

1. **Run Migration**
   ```bash
   rails db:migrate
   ```

2. **Restart Sidekiq** (to pick up new job schedule)
   ```bash
   # Kill and restart your Sidekiq workers
   ```

3. **Test the Feature**
   - Go to user profile page
   - Click "Automatische opwaardering" tab
   - Click "Mandate instellen"
   - Complete 1-cent payment in Mollie
   - You'll be redirected and can now toggle auto-charge

## Feature Details

### User Experience Flow

1. **Setup Mandate**
   - User sees "Mandate instellen" button
   - Clicks button → redirected to Mollie for 1-cent payment
   - Upon success → mandate is saved
   - Checkbox becomes enabled

2. **Toggle Auto-Charge**
   - User checks "Automatische opwaardering inschakelen"
   - Setting is saved to database

3. **Auto-Charge Execution**
   - Daily at 3 AM, system checks all users with auto-charge enabled
   - If balance < 0, system charges via SEPA mandate
   - Amount = |balance| + 1 euro (capped at 50 euros)
   - User gets payment record in their history

### Configuration

**Daily charge time**: Edit `config/sidekiq.yml`
```yaml
AutoChargeJob:
  cron: '0 3 * * *'  # Change this time as needed
```

See https://crontab.guru for cron format help.

## API Integration

The feature uses the Mollie API:
- [Customer Management](https://docs.mollie.com/reference/create-customer)
- [SEPA Mandates](https://docs.mollie.com/payments/recurring)
- [Recurring Payments](https://docs.mollie.com/payments/recurring)

Your `mollie_api_key` must be in `config/credentials.yml.enc`

## Troubleshooting

**Mandate not appearing after payment?**
- Check that payment was actually paid (not just submitted)
- Verify Mollie account is configured correctly
- Check job logs for errors

**Auto-charge not running?**
- Verify Sidekiq is running: `bundle exec sidekiq -C config/sidekiq.yml`
- Check Sidekiq logs for AutoChargeJob execution
- Verify a user has negative balance and auto-charge enabled

**Payment fails to create recurring charge?**
- Ensure mandate has valid status
- Check Mollie dashboard for mandate details
- Verify customer ID matches in database

## Testing Endpoint

Test the setup without real charges:
- Use Mollie test mode with test API key
- Use test credit card: `3782 822463 10005`
- Expiry: any future date, CVC: any 3 digits

## Key Security Features

✅ Mandate validation before charging
✅ Amount caps (max 50 euros) to prevent mistakes
✅ User must explicitly enable auto-charge
✅ Authorization checks on all endpoints
✅ Error logging and health monitoring
✅ Graceful error handling (continues with other users)

## Next Steps

1. Run the migration
2. Restart Sidekiq
3. Test with a user account
4. Monitor logs for the first auto-charge job run
5. Consider adding email notifications for future enhancement
