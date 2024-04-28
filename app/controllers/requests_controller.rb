class RequestsController < ApplicationController
  def index
    @initiative = Initiative.find(params[:initiative_id])
    @all_requests = @initiative.requests
    @active_requests = @initiative.requests.where(status: :pending)
    @old_requests = @initiative.requests.where(status: [:accepted, :denied])
  end
  def create
    @request = Request.new
    @request.user = current_user
    @request.status = params[:request][:status]
    @request.initiative = Initiative.find(params[:request][:initiative])
    if @request.save
      flash[:notice] = "Solicitud enviada correctamente"
      redirect_to initiative_path(params[:request][:initiative])
    else
      flash[:alert] = "Error al crear la solicitud"
      redirect_to initiative_path(params[:request][:initiative])
    end
  end

  def update
    @request = Request.find(params[:id])
    @request.status = request_params[:status]
    if @request.save
      flash[:notice] =  @request.status
      if @request.status == "accepted"
        @request.user.add_role(:member, @request.initiative)
        redirect_to initiative_requests_path(@request.initiative)
      elsif @request.status == "denied"
        redirect_to initiative_requests_path(@request.initiative)
      else
        redirect_to initiative_path(@request.initiative)
      end
    else
      flash[:alert] = "Error al actualizar la solicitud"
      redirect_to initiative_path(@request.initiative)
    end
  end

  private

  def request_params
    params.require(:request).permit(:status, :initiative)
  end
end