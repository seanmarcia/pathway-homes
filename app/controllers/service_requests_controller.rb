class ServiceRequestsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parms

  before_filter :authenticate_user!

  def index
    @service_requests = ServiceRequest.all
  end

  def new
    @service_request = ServiceRequest.new
  end

  def edit
  end

  def create
    @service_request = ServiceRequest.new(service_request_params)
    @service_request.creator = current_user

    respond_to do |format|
      if @service_request.save
        flash[:alert] = "Request ##{@service_request.id} was created!"
        format.html { render action: "index", status: :created }
      else
        flash[:alert] = @service_request.errors.full_messages.join('. ')
        format.html { render action: "new", status: :unprocessable_entity }
      end
    end
  end

  def update
    @service_request = ServiceRequest.find(params[:id])
    respond_to do |format|
      if @service_request.update(service_request_params)
        format.json { render action: "show" }
      else
        format.json { render json: @service_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @service_request = ServiceRequest.includes(:creator).find(params[:id])
  end


  def export
    service_requests = ServiceRequest.includes(:notes, :request_type).all

    send_data(service_requests.to_csv, :type => 'text/csv', :filename => 'service_requests.csv')
  end

  private

  def handle_missing_parms(exception)
    flash[:alert] = exception.message
    redirect_to new_service_request_path
  end

  def service_request_params
    params.require(:service_request).permit(
      :community_name, :apt_number, :work_desc, :special_instructions, :alarm,
      :community_street_address, :community_zip_code, :pet,
      :authorized_to_enter, :request_type_id, creator_attributes: [:name, :email, :phone]
    )
  end
end
