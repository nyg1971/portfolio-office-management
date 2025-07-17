# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Customers', type: :request do
  let!(:user) { create(:user) }
  let!(:department) { create(:department) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/customers' do
    let!(:customers) { create_list(:customer, 3, department: department) }

    context '認証あり' do
      it 'returns customer list with pagination' do
        get '/api/v1/customers', headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to have_key('customers')
        expect(response.parsed_body).to have_key('pagination')
        expect(response.parsed_body['customers'].size).to eq(3)

        # レスポンス構造の確認
        customer = response.parsed_body['customers'].first
        expect(customer).to have_key('id')
        expect(customer).to have_key('name')
        expect(customer).to have_key('customer_type')
        expect(customer).to have_key('customer_type_display')
        expect(customer).to have_key('status')
        expect(customer).to have_key('status_display')
        expect(customer).to have_key('department')
        expect(customer['department']).to have_key('id')
        expect(customer['department']).to have_key('name')
      end

      it 'supports pagination' do
        get '/api/v1/customers', headers: headers, params: { page: 1, per_page: 2 }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['customers'].size).to eq(2)
        expect(response.parsed_body['pagination']['current_page']).to eq(1)
        expect(response.parsed_body['pagination']['total_count']).to eq(3)
      end
    end

    context '認証なし' do
      it 'returns unauthorized error' do
        get '/api/v1/customers'

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end
    end

    context '無効なトークン' do
      it 'returns unauthorized error' do
        get '/api/v1/customers', headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end
    end
  end

  describe 'GET /api/v1/customers/:id' do
    let!(:customer) { create(:customer, department: department) }

    context '認証あり' do
      it 'returns customer details' do
        get "/api/v1/customers/#{customer.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to have_key('customer')

        customer_data = response.parsed_body['customer']
        expect(customer_data['id']).to eq(customer.id)
        expect(customer_data['name']).to eq(customer.name)
        expect(customer_data['customer_type']).to eq(customer.customer_type)
        expect(customer_data['customer_type_display']).to eq('一般顧客')
        expect(customer_data['status_display']).to eq('アクティブ')
      end

      it 'returns not found for invalid id' do
        get '/api/v1/customers/99999', headers: headers

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_key('error')
        expect(response.parsed_body['error']).to eq('顧客が見つかりません')
      end
    end

    context '認証なし' do
      it 'returns unauthorized error' do
        get "/api/v1/customers/#{customer.id}"

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end
    end
  end

  describe 'POST /api/v1/customers' do
    let(:valid_params) do
      {
        customer: {
          name: '新規顧客株式会社',
          customer_type: 'regular',
          status: 'active',
          department_id: department.id
        }
      }
    end

    context '認証あり' do
      context '正常系' do
        it 'creates new customer' do
          expect do
            post '/api/v1/customers', params: valid_params, headers: headers, as: :json
          end.to change(Customer, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(response.parsed_body).to have_key('customer')

          customer_data = response.parsed_body['customer']
          expect(customer_data['name']).to eq('新規顧客株式会社')
          expect(customer_data['customer_type']).to eq('regular')
          expect(customer_data['customer_type_display']).to eq('一般顧客')
          expect(customer_data['status']).to eq('active')
          expect(customer_data['status_display']).to eq('アクティブ')
        end

        it 'creates premium customer' do
          premium_params = valid_params.deep_dup
          premium_params[:customer][:customer_type] = 'premium'

          post '/api/v1/customers', params: premium_params, headers: headers, as: :json

          expect(response).to have_http_status(:created)
          customer_data = response.parsed_body['customer']
          expect(customer_data['customer_type']).to eq('premium')
          expect(customer_data['customer_type_display']).to eq('プレミアム顧客')
        end
      end

      context '異常系' do
        it 'returns validation errors for invalid params' do
          invalid_params = {
            customer: {
              name: '', # 空の名前
              department_id: nil
            }
          }

          post '/api/v1/customers', params: invalid_params, headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to have_key('errors')
          expect(response.parsed_body['errors']).to be_an(Array)
          expect(response.parsed_body['errors']).not_to be_empty
        end

        it 'returns error for invalid department_id' do
          invalid_params = valid_params.deep_dup
          invalid_params[:customer][:department_id] = 99_999

          post '/api/v1/customers', params: invalid_params, headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body).to have_key('errors')
        end

        it 'returns validation error for invalid customer_type' do
          invalid_params = valid_params.deep_dup
          invalid_params[:customer][:customer_type] = 'invalid_type'

          post '/api/v1/customers', params: invalid_params, headers: headers, as: :json

          expect(response).to have_http_status(:bad_request)
          expect(response.parsed_body).to have_key('error')
          expect(response.parsed_body['error']).to eq('パラメータが不正です')
          expect(response.parsed_body['message']).to include('invalid_type')
        end

        it 'returns error for missing required fields' do
          empty_params = { customer: {} }

          post '/api/v1/customers', params: empty_params, headers: headers, as: :json

          expect(response).to have_http_status(:bad_request)
          expect(response.parsed_body).to have_key('error')
        end
      end
    end

    context '認証なし' do
      it 'returns unauthorized error' do
        post '/api/v1/customers', params: valid_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end
    end

    context '無効なトークン' do
      it 'returns unauthorized error' do
        invalid_headers = { 'Authorization' => 'Bearer invalid_token' }
        post '/api/v1/customers', params: valid_params, headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end
    end
  end

  describe '権限チェック（将来の拡張用）' do
    let!(:staff_user) { create(:user, :staff) }
    let!(:admin_user) { create(:user, :admin) }
    let(:staff_token) { JsonWebToken.encode(user_id: staff_user.id) }
    let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }

    it 'staff user can access customers' do
      get '/api/v1/customers', headers: { 'Authorization' => "Bearer #{staff_token}" }
      expect(response).to have_http_status(:ok)
    end

    it 'admin user can access customers' do
      get '/api/v1/customers', headers: { 'Authorization' => "Bearer #{admin_token}" }
      expect(response).to have_http_status(:ok)
    end
  end
end
