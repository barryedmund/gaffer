class Presenters::Team < Presenters::BasePresenter
  def cash_balance_to_currency
    helper.number_to_currency(cash_balance_cents, :precision => 0)
  end

  def convert_number_to_currency(number)
    helper.number_to_currency(number, :precision => 0)
  end  

  private

  def helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end
end
