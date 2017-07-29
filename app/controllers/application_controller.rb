class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def model_class
    raise NotImplementedError
  end

  private

  def set_model
    @model = model_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def records(objects = nil)
    objects ||= model_class.all
    records = params[:filter] ? filtered_objects(objects) : objects
    records = sort(records)
    records = records.page(page_number).per(page_size) if page_number || page_size
    records
  end

  def sort(records)
    return records unless params[:sort]

    fields = params[:sort].split(',')
    permitted_sorting_fields = fields_with_order(fields).select do |key|
      model_class.column_names.include?(key)
    end
    records.order(permitted_sorting_fields)
  end

  def filtered_objects(objects = nil)
    objects ||= model_class.all
    filters = params.require(:filter).permit(permitted_filter_attributes).to_h
    filters.keys.inject(objects) do |filtered_objects, attribute|
      filtered_objects.where(attribute => filters[attribute].split(','))
    end
  end

  def model_includes
    []
  end

  def page_number
    params[:page].try(:[], :number)
  end

  def page_size
    params[:page].try(:[], :size)
  end
end
