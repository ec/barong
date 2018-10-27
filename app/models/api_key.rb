# frozen_string_literal: true

# -*- SkipSchemaAnnotations
# model for saving user api key pairs
class APIKey < ApplicationRecord
  serialize :scopes, Array

  JWT_OPTIONS = {
    verify_expiration: true,
    verify_iat: true,
    verify_jti: true,
    sub: 'api_key_jwt',
    verify_sub: true,
    iss: 'external',
    verify_iss: true,
    algorithm: 'RS256'
  }.freeze

  before_create :set_uid
  validates :account_id, :kid, presence: true

  belongs_to :account
  scope :active, -> { where(state: 'active') }

private

  def set_uid
    self.uid = SecureRandom.uuid
  end

end

# == Schema Information
# Schema version: 20180503073934
#
# Table name: api_keys
#
#  uid        :string(36)       not null, primary key
#  public_key :text(65535)      not null
#  scopes     :string(255)
#  expires_in :integer          not null
#  state      :string(255)      default("active"), not null
#  account_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_api_keys_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
