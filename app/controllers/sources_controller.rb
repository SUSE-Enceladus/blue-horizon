# frozen_string_literal: true

class SourcesController < ApplicationController
  before_action :set_sources, only: [:index, :show, :new, :edit]
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  # GET /sources
  def index; end

  # GET /sources/1
  def show; end

  # GET /sources/new
  def new
    @source = Source.new
  end

  # GET /sources/1/edit
  def edit; end

  # POST /sources
  def create
    @source = Source.new(source_params)

    if @source.save
      @source.export
      redirect_to(
        edit_source_path(@source),
        notice: 'Source was successfully created.'
      )
    else
      set_sources
      render :new
    end
  end

  # PATCH/PUT /sources/1
  def update
    if @source.update(source_params)
      @source.export
      redirect_to(
        edit_source_path(@source),
        notice: 'Source was successfully updated.'
      )
    else
      set_sources
      render :edit
    end
  end

  # DELETE /sources/1
  def destroy
    @source.destroy
    redirect_to(sources_path, notice: 'Source was successfully destroyed.')
  end

  private

  def set_sources
    @sources = Source.all.order(:filename)
  end

  def set_source
    @source = Source.find(params[:id])
  end

  def source_params
    params.require(:source).permit(:filename, :content)
  end
end
