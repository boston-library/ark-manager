# frozen_string_literal: true

class ArkMinter < Noid::Rails::Minter::Base
  attr_reader :minter_state

  def initialize(template = default_template)
    super(template)
    @minter_state = Noid::Minter.new(template: template)
  end


  def mint
    ActiveRecord::Base.connection_pool.with_connection do
      Mutex.new.synchronize do
        while noid = next_id do
          break noid unless ark_exists?(noid)
        end
      end
    end
  end

  protected
  def ark_exists?(noid)
    ::Ark.select(:id, :noid).lock.exists?(noid: noid)
  end

  def next_id
    minter_state.seed($$)
    minter_state.mint
  end
end
