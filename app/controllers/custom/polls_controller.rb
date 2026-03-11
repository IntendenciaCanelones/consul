class PollsController < ApplicationController
  include FeatureFlags
  include PollsHelper

  feature_flag :polls

  before_action :load_poll, except: [:index]
  before_action :load_active_poll, only: :index

  load_and_authorize_resource

  has_filters %w[current expired]
  has_orders %w[most_voted newest oldest], only: :show

  def index
    scope = @polls.created_by_admin
                  .not_budget
                  .send(@current_filter)
                  .includes(:geozones)

    if @current_filter == "expired"
      # Terminadas: ordenar por fin DESC y paginar como relation (SQL)
      @polls = scope.reorder(ends_at: :desc, id: :desc).page(params[:page])
    else
      # Activas: mantener orden de CONSUL y, si el usuario tiene municipio, priorizar las del suyo
      list = scope.sort_for_list

      if user_signed_in? && current_user.geozone_id.present?
        my_gid = current_user.geozone_id

        indexed = list.each_with_index.to_a
        indexed.sort_by! do |poll, idx|
          mine = poll.geozone_restricted && poll.geozones.any? { |g| g.id == my_gid }
          [mine ? 0 : 1, idx]  # primero las del municipio, manteniendo el orden original del resto
        end

        list = indexed.map(&:first)
      end

      @polls = Kaminari.paginate_array(list).page(params[:page])
    end
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions)
                                                    .where.not(description: "").order(:given_order)

    @answers_by_question_id = {}
    poll_answers = ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user&.id)
    poll_answers.each do |answer|
      @answers_by_question_id[answer.question_id] = answer.answer
    end

    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def stats
    @stats = Poll::Stats.new(@poll)
  end

  def results
  end

  private

    def load_poll
      @poll = Poll.find_by_slug_or_id!(params[:id])
    end

    def load_active_poll
      @active_poll = ActivePoll.first
    end
end
