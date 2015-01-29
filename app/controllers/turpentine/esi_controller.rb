class Turpentine::EsiController < ApplicationController
  include Turpentine::EsiSupport

  def view
    locals = params_to_locals params.except(:partial)
    render partial: params[:partial].gsub(/\-/, '/'), locals: locals
  end

end
