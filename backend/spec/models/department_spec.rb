# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Department, type: :model do
  describe 'associations' do
    it { should have_many(:customers).dependent(:restrict_with_error) }
    it { should have_many(:work_records).through(:customers) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 0, inactive: 1, archived: 2).with_prefix(:status) }
    it do
      should define_enum_for(:department_type)
        .with_values(sales: 0, engineering: 1, administration: 2, support: 3, other: 4)
        .with_prefix(:type)
    end
  end

  describe 'validations' do
    subject { build(:department) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'validates presence of name' do
      subject.name = nil
      subject.valid?
      expect(subject.errors[:name]).to include(a_string_matching('部署名'))
    end

    it 'validates uniqueness of name' do
      create(:department, name: '営業部')
      department = build(:department, name: '営業部')
      department.valid?
      expect(department.errors[:name]).to include(a_string_matching('部署名'))
    end

    it 'validates max length of name (100 characters)' do
      subject.name = 'あ' * 101
      subject.valid?
      expect(subject.errors[:name]).to include(a_string_matching('部署名'))
    end

    it 'validates japanese format for name' do
      subject.name = 'InvalidDept!@#'
      subject.valid?
      expect(subject.errors[:name]).to include(a_string_matching('部署名'))
    end

    it 'validates max length of address (500 characters)' do
      subject.address = 'あ' * 501
      subject.valid?
      expect(subject.errors[:address]).to include(a_string_matching('住所'))
    end

    it 'allows blank address' do
      subject.address = ''
      expect(subject).to be_valid
    end
  end
end
