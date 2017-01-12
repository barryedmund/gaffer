class AuctionsController < InheritedResources::Base
  before_action :require_user

  def new
    @auction = Auction.new
  end

  private
  def auction_params
    params.require(:auction).permit()
  end
end

