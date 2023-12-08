class Api::HomeController < ApplicationController
  def data
    response = Api::BuildDataResponse.new(permitted_params).call
    render json: response, status: :ok
  end

  protected

  def permitted_params
    params.permit(:url, fields: {})
  end
end
