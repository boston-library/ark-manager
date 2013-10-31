class Scripts
  def self.fixToNewFormatCollection
    arks = Ark.all
    arks.each do |ark|
      if ark.model_type == 'Bplmodels::Collection'
        collection_object = nil

        begin
          collection_object = Bplmodels::Collection.find(ark.pid)
        rescue
          ark.delete!

        end

        if collection_object == nil
          ark.delete!
        else
          parent_object= collection_object.institutions
          ark.parent_pid = parent_object.pid
          ark.local_original_identifier = collection_object.label
          ark.local_original_identifier_type = 'Institution Collection Name'
          ark.save!


=begin
          if ark.local_original_identifier.split(' ').length > 1
            pid_part = ark.local_original_identifier.split(' ').first
            ark.parent_pid = pid_part
            ark.local_original_identifier =  ark.local_original_identifier.slice((ark.local_original_identifier.index(' '))+1..ark.local_original_identifier.length)
            ark.local_original_identifier_type = 'Institution Collection Name'

            puts 'Collection Object'
            puts ark.parent_pid
            puts ark.local_original_identifier
            puts ark.local_original_identifier_type
            puts ark.pid

            if collection_object.label !=    ark.local_original_identifier
              puts '-------DANGER-------DANGER------DANGER'
              ark.pid
            end

            #ark.save!
          elsif ark.local_original_identifier.include?('hdl')
            parent_object= collection_object.institutions
            ark.parent_pid = parent_object.pid
            ark.local_original_identifier = collection_object.label
            ark.local_original_identifier_type = 'Institution Collection Name'

            puts '---HDL OBJECT---'
            puts ark.parent_pid
            puts ark.local_original_identifier
            puts ark.local_original_identifier_type
            puts ark.pid

            if collection_object.label !=    ark.local_original_identifier
              puts '-------DANGER-------DANGER------DANGER'
              ark.pid
            end

            #Dpsace Collections - seems fine?
          else
            puts '------------Bad Ark---------------'
            puts ark.local_original_identifier
            puts ark.local_original_identifier_type
            puts ark.pid
          end
=end
        end



      end
    end
  end

  #Bug with Dspace objects? May need to test on production.
  def self.fixToNewFormatObject
    arks = Ark.all
    arks.each do |ark|
      if ark.model_type == 'Bplmodels::Collection'

      elsif ark.model_type == 'Bplmodels::File'
        #Fixed after everything else in another script
      elsif ark.model_type == 'Bplmodels::Institution'
        #Do nothing
      else
        begin
          object = ActiveFedora::Base.find(ark.pid)
        rescue
          ark.delete!

        end

        if object == nil
          ark.delete!
        else

          if ark.local_original_identifier_type.split(' ').length > 1
            pid_part = ark.local_original_identifier_type.split(' ').first
            ark.parent_pid = pid_part
            ark.local_original_identifier = ark.local_original_identifier_type.slice((ark.local_original_identifier_type.index(' '))+1..ark.local_original_identifier_type.length)

            puts 'Regular Object'
            puts ark.parent_pid
            puts ark.local_original_identifier
            puts ark.local_original_identifier_type
            #ark.save!
          else
            puts '------------Bad Ark---------------'
            puts ark.local_original_identifier
            puts ark.local_original_identifier_type
            puts ark.pid
          end
        end

      end
    end
  end


  def self.fixToNewFormatFiles
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