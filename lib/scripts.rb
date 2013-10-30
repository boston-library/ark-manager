class Scripts
  def self.fixToNewFormat
    arks = Ark.all
    arks.each do |ark|
      if ark.model_type == 'Bplmodels::Collection'
        pid_part = ark.local_original_identifier.split(' ').first
        ark.parent_pid = pid_part
        ark.local_original_identifier =  ark.local_original_identifier.slice((ark.local_original_identifier.index(' '))+1..ark.local_original_identifier.length)
        ark.local_original_identifier_type = 'Institution Collection Name'

        puts 'Collection Object'
        puts ark.parent_pid
        puts ark.local_original_identifier
        puts ark.local_original_identifier_type

        #ark.save!
      elsif ark.model_type == 'Bplmodels::File'
        #Fixed after everything else in another script
      elsif ark.model_type == 'Bplmodels::Institution'
        #Do nothing
      else
        pid_part = ark.local_original_identifier_type.split(' ').first
        ark.parent_pid = pid_part
        ark.local_original_identifier = ark.local_original_identifier_type.slice((ark.local_original_identifier_type.index(' '))+1..ark.local_original_identifier_type.length)

        puts 'Regular Object'
        puts ark.parent_pid
        puts ark.local_original_identifier
        puts ark.local_original_identifier_type
        #ark.save!
      end
    end
  end


  def self.fixFilesToNewFormat
    arks = Ark.all
    arks.each do |ark|
      if ark.model_type == 'Bplmodels::File'
        local_id_of_parent = ark.local_original_identifier.split(' ').first
        local_id_type_of_parent =  ark.local_original_identifier_type.split(' ').first
        parent_record = Ark.where(:local_original_identifier=>local_id_of_parent, :local_id_type_of_parent=>local_id_type_of_parent)

        ark.parent_pid = parent_record.pid
        ark.local_original_identifier = Bplmodels::File.find(ark.pid).workflowMetadata.item_source.ingest_filepath.split('/').last
        ark.local_original_identifier_type = 'File'

        puts 'File Object'
        puts ark.parent_pid
        puts ark.local_original_identifier
        puts ark.local_original_identifier_type
        #ark.save!
      end
    end

  end
end