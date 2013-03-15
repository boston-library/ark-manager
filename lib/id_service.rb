
class IdService
  @@minter = Noid::Minter.new(:template => '.reeddeeddk')

  #@@namespace = ScholarSphere::Application.config.id_namespace

  def self.valid?(identifier)
    # remove the fedora namespace since it's not part of the noid
    noid = identifier.split(":").last
    return @@minter.valid? noid
  end
  def self.mint(namespace = nil)
    while true
      pid = self.next_id(namespace)
      break
      # unless ActiveRecord::Base.exists?(pid)
    end
    return pid
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