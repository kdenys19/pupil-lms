class TargetsController < ApplicationController
  include CamelizeKeys
  include StringifyIds

  before_action :preview_or_authenticate

  # GET /targets/:id/(:slug)
  def show
    @presenter = Targets::ShowPresenter.new(view_context, @target)
    render 'courses/curriculum', layout: 'student_course'
  end

  # GET /targets/:id/details
  def details_v2
    student =
      current_user
        .founders
        .joins(:course)
        .where(courses: { id: @course.id })
        .first if current_user.present?

    render json:
             camelize_keys(
               stringify_ids(
                 Targets::DetailsService.new(
                   @target,
                   student,
                   public_preview: current_user.blank?
                 ).details
               )
             )
  end

  private

  def preview_or_authenticate
    target = Target.find(params[:id])
    @course = target.course

    authenticate_user! unless @course.public_preview?

    @target = authorize(target)
  end
end
