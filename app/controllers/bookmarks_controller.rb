class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_job_seeker!

  def index
    @bookmarks = current_user.bookmarks
                            .includes(job: :company)
                            .order(created_at: :desc)
                            .page(params[:page]).per(12)
  end

  def destroy
    @bookmark = current_user.bookmarks.find(params[:id])
    @bookmark.destroy

    redirect_to bookmarks_path, notice: "Job removed from bookmarks."
  end

  private

  def ensure_job_seeker!
    redirect_to root_path, alert: "Access Denied." unless current_user.job_seeker?
  end
end
