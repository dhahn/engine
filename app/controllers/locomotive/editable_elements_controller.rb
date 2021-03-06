module Locomotive
  class EditableElementsController < BaseController

    account_required & within_site

    localized

    before_filter :load_page

    layout 'locomotive/layouts/preview'

    def index
      authorize @page
      respond_with(@page) do |format|
        format.html { render_index }
      end
    end

    private

    def render_index
      if request.xhr?
        render partial: 'form'
      else
        render 'index'
      end
    end

    def load_page
      @page = current_site.pages.find(params[:page_id])
    end


  end
end
