require 'base64'

class BurndownchartController < ApplicationController
  def index
    if current_user
      client = Octokit::Client.new access_token: current_user.access_token
      client.auto_paginate = true

      dataset = current_user.get_burndownchart_dataset(params['repo'], params['base_day'])

      @open_total_points = dataset[:open_total_points]
      @closed_total_points = dataset[:closed_total_points]
      @data_labels = dataset[:data_labels]
      @dataset1 = dataset[:dataset1]
      @dataset2 = dataset[:dataset2]

      g = Gruff::Line.new
      g.title = 'Burn Down Chart'
      g.labels = label_to_hash(@data_labels)
      g.data :Plan, @dataset1
      g.data :Result, @dataset2
      g.theme_pastel
      @img = 'data:image/png;base64,' + Base64.strict_encode64(g.to_blob)
    end
  end

  private

  def label_to_hash(labels)
    Hash[*[*0..4].zip(labels).flatten]
  end
end
