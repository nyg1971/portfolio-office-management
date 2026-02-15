# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkRecord, type: :model do
  describe 'associations' do
    it { should belong_to(:customer) }
    it { should belong_to(:staff_user).class_name('User') }
    it { should belong_to(:department) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:status)
        .with_values(in_progress: 0, completed: 1, on_hold: 2, cancelled: 3)
        .with_prefix(:status)
    end
    it do
      should define_enum_for(:work_type)
        .with_values(consultation: 0, support: 1, maintenance: 2, emergency: 3)
        .with_prefix(:type)
    end
  end

  describe 'validations' do
    subject { build(:work_record) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'validates presence of content' do
      subject.content = nil
      subject.valid?
      expect(subject.errors[:content]).to include(a_string_matching('作業内容'))
    end

    it 'validates max length of content (1000 characters)' do
      subject.content = 'あ' * 1001
      subject.valid?
      expect(subject.errors[:content]).to include(a_string_matching('作業内容'))
    end

    it 'validates presence of work_date' do
      subject.work_date = nil
      subject.valid?
      expect(subject.errors[:work_date]).to include(a_string_matching('作業日'))
    end
  end

  describe 'callbacks' do
    it 'sets default status to in_progress on create' do
      work_record = build(:work_record, status: nil)
      work_record.save!
      expect(work_record.status).to eq('in_progress')
    end

    it 'does not override existing status on create' do
      work_record = create(:work_record, status: :completed)
      expect(work_record.status).to eq('completed')
    end
  end
end
