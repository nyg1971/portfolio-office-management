# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BaseController
      rescue_from ActiveRecord::RecordNotFound, with: :customer_not_found
      before_action :set_customer, only: %i[show update destroy]

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

      # PATCH/PUT /api/v1/customers/1
      def update
        if @customer.update(customer_params)
          render json: { customer: customer_json(@customer) }
        else
          render json: { errors: @customer.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      # DELETE /api/vi/customer/1
      def destroy
        @customer.destroy
        head :no_content # 204 No Content(削除成功)
      rescue ActiveRecord::InvalidForeignKey => e
        render json: {
          error: '関連データがあるため削除できません',
          details: e.message
        }, status: :unprocessable_entity
      end

      private

      def customer_not_found(exception)
        render json: {
          error: '顧客が見つかりません',
          message: exception.message
        }, status: :not_found
      end

      def set_customer
        @customer = Customer.find(params[:id])
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
