class MinterService < ApplicationService

  def initialize(namespace: Noid::Rails.config.namespace)
    @minter = Noid::Rails.config.minter_class.new(Noid::Rails.config.template, namespace)
  end

  def call
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        
      end
    rescue => e
      puts e.message
    end

    nil
  end
end
