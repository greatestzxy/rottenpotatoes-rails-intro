class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    if params[:ratings].blank?
      @ratings_to_show = []
      @saved_ratings = {}
    else
      @ratings_to_show = params[:ratings].keys
      @saved_ratings = params[:ratings]
    end


    if params[:sort]
      if params[:sort].keys[0]=='sort_by_title'
        @movies = Movie.with_ratings(@ratings_to_show).order(:title)
        @title_color = 'bg-warning'
        @date_color = 'bg-white'
        session[:sort]={'sort_by_title'=>1}

      elsif params[:sort].keys[0]=='sort_by_release_date'
        @movies = Movie.with_ratings(@ratings_to_show).order(:release_date)
        @title_color = 'bg-white'
        @date_color = 'bg-warning'
        session[:sort]={'sort_by_release_date'=>1}
      end

    elsif session[:sort] && session[:saved_ratings]
      if session[:sort].keys[0]=='sort_by_release_date'
        @movies = Movie.with_ratings(session[:saved_ratings]).order(:release_date)
        @title_color = 'bg-white'
        @date_color = 'bg-warning'
        redirect_to action: :index, sort:{'release_date'=>1}, saved_ratings: session[:saved_ratings]
      elsif params[:sort].keys[0]=='sort_by_title'
        @movies = Movie.with_ratings(session[:saved_ratings]).order(:title)
        @title_color = 'bg-white'
        @date_color = 'bg-warning'
        redirect_to action: :index, sort:{'title'=>1}, saved_ratings: session[:saved_ratings]
      end

    elsif session[:saved_ratings]
      @movies = Movie.with_ratings(session[:saved_ratings].keys)
    else
      @movies = Movie.with_ratings(@ratings_to_show)
      @title_color = 'bg-white'
      @date_color = 'bg-white'
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
