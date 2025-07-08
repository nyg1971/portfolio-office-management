# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BaseController
      before_action :set_customer, only: [:show]

      # GET /api/v1/customers
      def index
        @customers = Customer.includes(:department)
                             .page(params[:page])
                             .per(params[:per_page] || 20)

        render json: {
          customers: @customers.map(&method(:customer_json)),
          pagination: {
            current_page: @customers.current_page,
            total_pages: @customers.total_pages,
            total_count: @customers.total_count
          }
        }
      end

      # GET /api/v1/customers/1
      def show
        render json: { customer: customer_json(@customer) }
      end

      # POST /api/v1/customers
      def create
        @customer = Customer.new(customer_params)

        if @customer.save
          render json: { customer: customer_json(@customer) }, status: :created
        else
          render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_customer
        @customer = Customer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: '顧客が見つかりません' }, status: :not_found
      end

      def customer_params
        params.require(:customer).permit(:name, :customer_type, :status, :department_id)
      end

      def customer_json(customer)
        {
          id: customer.id,
          name: customer.name,
          customer_type: customer.customer_type,
          customer_type_display: customer_type_display(customer.customer_type),
          status: customer.status,
          status_display: status_display(customer.status),
          department: {
            id: customer.department.id,
            name: customer.department.name
          },
          created_at: customer.created_at,
          updated_at: customer.updated_at
        }
      end

      def customer_type_display(customer_type)
        choices = Validatable::ConfigurationManager.get_choice_display_names('customer', 'customer_type')
        choices[customer_type] || customer_type
      end

      def status_display(status)
        choices = Validatable::ConfigurationManager.get_choice_display_names('customer', 'status')
        choices[status] || status
      end
    end
  end
end
