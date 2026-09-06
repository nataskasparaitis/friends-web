class Friend < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name,  presence: true, length: { maximum: 50 }
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" }
  validates :phone,   length: { maximum: 30 },  allow_blank: true
  validates :twitter, length: { maximum: 50 },  allow_blank: true

  # Case-insensitive partial match across the fields shown in the friends table.
  # Returns the relation unchanged when the query is blank, so it stays chainable
  # off current_user.friends whether or not the navbar search was used.
  def self.search(query)
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query.to_s.strip)}%"
    columns = %w[ first_name last_name email phone twitter ]

    # ESCAPE is required for the backslashes sanitize_sql_like inserts to be
    # treated as escapes, so a query containing % or _ matches literally.
    where(columns.map { |c| "#{c} LIKE :q ESCAPE '\\'" }.join(" OR "), q: pattern)
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
