class Presenters::Contract < Presenters::BasePresenter
  def salary_to_currency
    helper.number_to_currency(weekly_salary_cents, :precision => 0)
  end

  private

  def helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end
end
