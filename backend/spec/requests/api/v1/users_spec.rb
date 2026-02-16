# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let!(:admin_user) { create(:user, :admin) }
  let!(:staff_user) { create(:user) }
  let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }
  let(:staff_token) { JsonWebToken.encode(user_id: staff_user.id) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{admin_token}" } }
  let(:staff_headers) { { 'Authorization' => "Bearer #{staff_token}" } }

  describe 'GET /api/v1/users' do
    before { create_list(:user, 3) }

    context '認証あり' do
      it 'returns user list with pagination' do
        get '/api/v1/users', headers: admin_headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to have_key('users')
        expect(response.parsed_body).to have_key('pagination')
      end

      it 'supports pagination' do
        get '/api/v1/users', headers: admin_headers, params: { page: 1, per_page: 2 }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['users'].size).to eq(2)
        expect(response.parsed_body['pagination']['current_page']).to eq(1)
      end
    end

    context '認証なし' do
      it 'returns unauthorized error' do
        get '/api/v1/users'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    context '管理者がアクセス' do
      it 'returns user details' do
        get "/api/v1/users/#{staff_user.id}", headers: admin_headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to have_key('user')
      end
    end

    context '本人がアクセス' do
      it 'returns own user details' do
        get "/api/v1/users/#{staff_user.id}", headers: staff_headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to have_key('user')
      end
    end

    context 'スタッフが他ユーザーにアクセス' do
      it 'returns forbidden error' do
        get "/api/v1/users/#{admin_user.id}", headers: staff_headers

        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body['error']).to eq('アクセス権限がありません')
      end
    end

    context '存在しないユーザー' do
      it 'returns not found error' do
        get '/api/v1/users/99999', headers: admin_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context '認証なし' do
      it 'returns unauthorized error' do
        get "/api/v1/users/#{staff_user.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
