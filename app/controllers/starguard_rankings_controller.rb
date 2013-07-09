class StarguardRankingsController < ApplicationController
  def index
    @starguard_rankings = StarguardRanking.all
  end
  
  def show
    @starguard_ranking = StarguardRanking.find(params[:id])
  end
  
  def new
    @starguard_ranking = StarguardRanking.new
  end
  
  def create
    @starguard_ranking = StarguardRanking.new(params[:starguard_ranking])
    if @starguard_ranking.save
      flash[:notice] = "Successfully created starguard ranking."
      redirect_to @starguard_ranking
    else
      render :action => 'new'
    end
  end
  
  def edit
    @starguard_ranking = StarguardRanking.find(params[:id])
  end
  
  def update
    @starguard_ranking = StarguardRanking.find(params[:id])
    if @starguard_ranking.update_attributes(params[:starguard_ranking])
      flash[:notice] = "Successfully updated starguard ranking."
      redirect_to @starguard_ranking
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @starguard_ranking = StarguardRanking.find(params[:id])
    @starguard_ranking.destroy
    flash[:notice] = "Successfully destroyed starguard ranking."
    redirect_to starguard_rankings_url
  end
end
