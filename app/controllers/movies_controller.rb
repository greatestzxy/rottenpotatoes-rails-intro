class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings=Movie.all_ratings
    
    if params[:commit] == "Refresh"&&params[:ratings].blank?
      #session.delete(:ratings)
      @ratings_to_show = []
      @rating_for_sort={}
  
    elsif params[:ratings]
      @ratings_to_show=params[:ratings].keys
      @rating_for_sort=params[:ratings]
      session[:ratings]=params[:ratings]
      
    elsif session[:ratings]
      @ratings_to_show=session[:ratings].keys
      @rating_for_sort=session[:ratings]
    else
      @ratings_to_show=@all_ratings
      
    end 
  
    if params[:sorting_para]
      if params[:sorting_para].keys[0]=='title'
        @movies = Movie.with_ratings(@ratings_to_show).order(:title)
        @Title_color = "bg-warning"
        session[:sorting_para]={'title'=>1}
        
      elsif params[:sorting_para].keys[0]=='date'
        @movies = Movie.with_ratings(@ratings_to_show).order(:release_date)
        @Date_color = "bg-warning"
        session[:sorting_para]={'date'=>1}
      end 
    
    elsif session[:sorting_para]&&session[:ratings]
      if session[:sorting_para].keys[0]=='title'
         @movies = Movie.with_ratings(session[:ratings].keys).order(:title)
         @Title_color = "bg-warning"
         redirect_to action: :index, sorting_para:{'title'=>1}, ratings: session[:ratings]
      elsif session[:sorting_para].keys[0]=='date'
        @movies = Movie.with_ratings(session[:ratings].keys).order(:release_date)
        @Date_color = "bg-warning"   
        redirect_to action: :index, sorting_para:{'date'=>1}, ratings: session[:ratings]
      end
    
    elsif session[:ratings]
      @movies = Movie.with_ratings(session[:ratings].keys)
      #redirect_to action: :index, sorting_para:{'nothing'=>1}, ratings: session[:ratings]   
        
    else
      @movies = Movie.with_ratings(@ratings_to_show)
      session.clear
      @Date_color="bg-white"
      @Title_color="bg-white"
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