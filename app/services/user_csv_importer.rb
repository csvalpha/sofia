require 'csv'

# Imports streepsysteem (sofia_account) users from a CSV file.
#
# The import is all-or-nothing: when any row is invalid no user is created,
# so no activation mails are sent for a partially imported list.
class UserCsvImporter
  HEADERS = {
    'naam' => :name, 'name' => :name,
    'email' => :email, 'e-mail' => :email, 'e-mailadres' => :email,
    'geboortedatum' => :birthday, 'birthday' => :birthday,
    'subprovider' => :sub_provider, 'sub_provider' => :sub_provider
  }.freeze
  BYTE_ORDER_MARK = [0xFEFF].pack('U').freeze
  DATE_FORMAT = %r{\A(?<day>\d{1,2})[-/.](?<month>\d{1,2})[-/.](?<year>\d{4})\z}

  attr_reader :users, :errors

  def initialize(content)
    @content = normalize_encoding(content.to_s)
    @users = []
    @errors = []
  end

  def import
    rows = parse
    build_users(rows) if errors.empty?
    return false if errors.any?

    User.transaction { users.each(&:save!) }
    true
  rescue ActiveRecord::RecordInvalid => e
    errors << e.message
    false
  end

  private

  # Excel often saves CSV files as Windows-1252 and/or with a byte order mark
  def normalize_encoding(content)
    utf8 = content.dup.force_encoding('UTF-8')
    utf8 = content.dup.force_encoding('Windows-1252').encode('UTF-8') unless utf8.valid_encoding?
    utf8.delete_prefix(BYTE_ORDER_MARK)
  end

  def parse
    table = CSV.parse(@content, headers: true, col_sep:, header_converters: ->(header) { normalize_header(header) })
    validate_headers(table.headers)
    errors << 'Het bestand bevat geen gebruikers' if errors.empty? && table.all? { |row| blank_row?(row) }
    table
  rescue CSV::MalformedCSVError => e
    errors << "Het bestand kon niet gelezen worden (#{e.message})"
    []
  end

  def normalize_header(header)
    key = header.to_s.strip.downcase
    HEADERS.fetch(key, key)
  end

  # Dutch Excel saves CSV files with semicolons, so support both separators
  def col_sep
    first_line = @content.lines.first.to_s
    first_line.count(';') > first_line.count(',') ? ';' : ','
  end

  def validate_headers(headers)
    required = %i[name email]
    required << :sub_provider if sub_provider_required?
    missing = required - headers
    return if missing.empty?

    errors << "Ontbrekende kolom(men): #{missing.map { |h| HEADERS.key(h) }.join(', ')}"
  end

  def build_users(rows)
    rows.each.with_index(2) do |row, line|
      next if blank_row?(row)

      user = build_user(row, line)
      messages = row_errors(user)
      errors << "Rij #{line}: #{messages.join(', ')}" if messages.any?
      users << user
    end
  end

  def build_user(row, line)
    User.new(provider: 'sofia_account', name: row[:name]&.strip, email: row[:email]&.strip,
             sub_provider: row[:sub_provider]&.strip&.upcase.presence, birthday: parse_birthday(row[:birthday], line))
  end

  def row_errors(user)
    messages = user.valid? ? [] : user.errors.full_messages
    messages << 'E-mailadres moet ingevuld zijn' if user.email.blank?
    messages << 'Subprovider moet ingevuld zijn' if sub_provider_required? && user.sub_provider.blank?
    messages << 'E-mailadres staat meerdere keren in het bestand' if duplicate_email?(user)
    messages.uniq
  end

  def duplicate_email?(user)
    user.email.present? && users.any? { |other| other.email.to_s.casecmp?(user.email) }
  end

  def parse_birthday(value, line)
    return nil if value.blank?

    date = parse_date(value.strip)
    return date if date && date <= Time.zone.today

    errors << "Rij #{line}: Geboortedatum '#{value.strip}' is ongeldig, gebruik DD-MM-JJJJ"
    nil
  rescue Date::Error
    errors << "Rij #{line}: Geboortedatum '#{value.strip}' bestaat niet"
    nil
  end

  def parse_date(value)
    match = DATE_FORMAT.match(value)
    match && Date.new(match[:year].to_i, match[:month].to_i, match[:day].to_i)
  end

  def blank_row?(row)
    row.fields.all?(&:blank?)
  end

  def sub_provider_required?
    Rails.application.config.x.subprovider_label.present?
  end
end
