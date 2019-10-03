class MinterService < ApplicationService
  TEMPLATE='.reeddeeddk'.freeze

  def initialize
    @semaphore = Mutex.new
    @minter = Noid::Minter.new(:template => TEMPLATE)
  end
  # #@@namespace = ScholarSphere::Application.config.id_namespace
  #
  # def valid?(noid)
  #   # remove the fedora namespace since it's not part of the noid
  #   noid = identifier.split(":").last
  #   @minter.valid?(noid)
  # end



  def call
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      Thread.new{ mint }.join.value
    end
  end

  protected

  def mint
    Rails.application.executor.wrap do
      ActiveRecord::Base.connection_pool.with_connection do
        @semaphore.synchronize do
          while noid = next_id
            return noid unless Ark.unscoped.exists?(noid: noid)
          end
        end
      end
    end
  end

  def next_id
    # seed with process id so that if two processes are running they do not come up with the same id.
    @minter.seed($$)
    @minter.mint
  end
end
