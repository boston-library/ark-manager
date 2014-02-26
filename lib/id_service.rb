
class IdService
  @@minter = Noid::Minter.new(:template => '.reeddeeddk')
  @semaphore = Mutex.new

  #@@namespace = ScholarSphere::Application.config.id_namespace

  def self.valid?(identifier)
    # remove the fedora namespace since it's not part of the noid
    noid = identifier.split(":").last
    return @@minter.valid? noid
  end
  def self.mint(namespace = nil)
    @semaphore.synchronize do
      while true
        pid = self.next_id(namespace)
        return pid unless Ark.exists?(:noid=>getid(pid))
        #TODO: Check again fedora and update to - https://github.com/projecthydra/sufia/blob/a0d7571410a9c33b279da2c3221399a82fd9f6a7/sufia-models/lib/sufia/models/id_service.rb
      end
    end

  end

  def self.getid(pid)
    pid.split(":").last
  end

  def self.getNamespace(pid)
    pid.split(":").first
  end

  protected
  def self.next_id(namespace)
    # seed with process id so that if two processes are running they do not come up with the same id.
    @@minter.seed($$)
    return "#{namespace}:#{@@minter.mint}"
  end
end