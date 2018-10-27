# frozen_string_literal: true

RSpec.describe APIKey, type: :model do
  it { should validate_presence_of(:account_id) }
  it { should validate_presence_of(:kid) }

end
