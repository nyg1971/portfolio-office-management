# frozen_string_literal: true

# 属性名管理専用ファイル

module Validatable
  module ManagedAttributes
    # === 基本属性 ===
    BASIC_ATTRIBUTES = {
      name: '名前',
      email: 'メールアドレス',
      phone: '電話番号',
      address: '住所',
      postal_code: '郵便番号'
    }.freeze

    # === ユーザー関連属性 ===
    USER_ATTRIBUTES = {
      username: 'ユーザー名',
      password: 'パスワード',
      password_confirmation: 'パスワード確認',
      display_name: '表示名',
      furigana: 'フリガナ',
      bio: '自己紹介',
      profile_image: 'プロフィール画像'
    }.freeze

    # === 組織関連属性 ===
    ORGANIZATION_ATTRIBUTES = {
      department_name: '部署名',
      company_name: '会社名',
      organization_name: '組織名',
      division_name: '事業部名',
      team_name: 'チーム名'
    }.freeze

    # === 商品・サービス関連属性 ===
    PRODUCT_ATTRIBUTES = {
      product_name: '商品名',
      service_name: 'サービス名',
      category_name: 'カテゴリ名',
      brand_name: 'ブランド名',
      model_name: 'モデル名',
      price: '価格',
      description: '説明',
      specifications: '仕様'
    }.freeze

    # === コンテンツ関連属性 ===
    CONTENT_ATTRIBUTES = {
      title: 'タイトル',
      content: '内容',
      summary: '概要',
      remarks: '備考',
      notes: 'メモ',
      comment: 'コメント',
      message: 'メッセージ'
    }.freeze

    # === 日時・メタ情報 ===
    META_ATTRIBUTES = {
      created_at: '作成日時',
      updated_at: '更新日時',
      published_at: '公開日時',
      deleted_at: '削除日時',
      status: 'ステータス',
      priority: '優先度',
      order: '並び順'
    }.freeze

    # === 位置・地理情報 ===
    LOCATION_ATTRIBUTES = {
      latitude: '緯度',
      longitude: '経度',
      prefecture: '都道府県',
      city: '市区町村',
      building: '建物名',
      room_number: '部屋番号'
    }.freeze

    # === 連絡先情報 ===
    CONTACT_ATTRIBUTES = {
      mobile_phone: '携帯電話',
      fax: 'FAX',
      website: 'ウェブサイト',
      social_media: 'SNS',
      emergency_contact: '緊急連絡先'
    }.freeze

    # === 全属性を統合 ===
    ALL_ATTRIBUTES = BASIC_ATTRIBUTES
                     .merge(USER_ATTRIBUTES)
                     .merge(ORGANIZATION_ATTRIBUTES)
                     .merge(PRODUCT_ATTRIBUTES)
                     .merge(CONTENT_ATTRIBUTES)
                     .merge(META_ATTRIBUTES)
                     .merge(LOCATION_ATTRIBUTES)
                     .merge(CONTACT_ATTRIBUTES)
                     .freeze

    # === 属性追加のヘルパーメソッド ===
    def self.list_all_attributes
      Rails.logger.debug '=== 管理されている属性一覧 ==='
      ALL_ATTRIBUTES.each do |key, value|
        Rails.logger.debug ":#{key.to_s.ljust(20)} => \"#{value}\""
      end
      Rails.logger.debug { "\n合計: #{ALL_ATTRIBUTES.size}個" }
    end

    def self.search_attribute(keyword)
      matches = ALL_ATTRIBUTES.select do |key, value|
        key.to_s.include?(keyword.to_s) || value.include?(keyword.to_s)
      end

      Rails.logger.debug { "=== '#{keyword}' の検索結果 ===" }
      matches.each do |key, value|
        Rails.logger.debug ":#{key} => \"#{value}\""
      end
    end

    def self.suggest_attribute_name(input)
      # 類似属性名の提案
      suggestions = ALL_ATTRIBUTES.keys.select do |key|
        key.to_s.include?(input.to_s) ||
          input.to_s.include?(key.to_s)
      end

      return unless suggestions.any?

      Rails.logger.debug 'もしかして以下の属性ですか？'
      suggestions.each { |s| Rails.logger.debug ":#{s}" }
    end
  end
end
