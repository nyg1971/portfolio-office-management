# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it 'validates presence of role' do
      user = User.new(email: 'test@example.com', password: 'password')
      user.role = nil
      user.valid?
      expect(user.errors[:role]).to include(a_string_matching('役職は必須です'))
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(staff: 0, manager: 1, admin: 2) }
  end
  describe 'default role' do
    it 'sets default role to staff' do
      # Given
      user = User.new(email: 'test@example.com', password: 'password')
      # Then
      expect(user.role).to eq('staff')
    end
  end
end
