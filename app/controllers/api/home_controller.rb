class Api::HomeController < ApplicationController
  def data
    status, response = Api::BuildDataResponse.new(permitted_params).call
    render json: response, status: status
  end

  protected

  def permitted_params
    params.permit(:url, fields: {})
  end
end
