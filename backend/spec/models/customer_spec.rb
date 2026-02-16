# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { should belong_to(:department) }
    it { should have_many(:work_records).dependent(:destroy) }
    it { should have_many(:assigned_users).through(:work_records) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 0, inactive: 1, pending: 2).with_prefix(:status) }
    it do
      should define_enum_for(:customer_type)
        .with_values(regular: 0, premium: 1, corporate: 2)
        .with_prefix(:type)
    end
  end

  describe 'validations' do
    subject { build(:customer) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'validates presence of name' do
      subject.name = nil
      subject.valid?
      expect(subject.errors[:name]).to include(a_string_matching('顧客名'))
    end

    it 'validates max length of name (100 characters)' do
      subject.name = 'あ' * 101
      subject.valid?
      expect(subject.errors[:name]).to include(a_string_matching('顧客名'))
    end

    it 'validates presence of status' do
      subject.status = nil
      subject.valid?
      expect(subject.errors[:status]).to include(a_string_matching('ステータス'))
    end

    it 'validates presence of customer_type' do
      subject.customer_type = nil
      subject.valid?
      expect(subject.errors[:customer_type]).to include(a_string_matching('顧客タイプ'))
    end
  end

  describe 'callbacks' do
    it 'does not override existing status on create' do
      customer = create(:customer, status: :active)
      expect(customer.status).to eq('active')
    end
  end
end
