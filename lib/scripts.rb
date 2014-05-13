class Scripts
  def self.fixToNewFormatCollection
    arks = Ark.all
    arks.each do |ark|
      if ark.model_type == 'Bplmodels::Collection' && ark.pid != ''
        collection_object = nil

        begin
          collection_object = Bplmodels::Collection.find(ark.pid)
        rescue
          ark.destroy

        end

        if collection_object == nil
          ark.destroy
        else
          puts ark.pid
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
      elsif ark.model_type == 'Bplmodels::ImageFile'
        #Fixed after everything else in another script
      elsif ark.model_type == 'Bplmodels::Institution'
        #Do nothing
      else
        #begin
          #object = ActiveFedora::Base.find(ark.pid)
        #rescue
          #ark.destroy

        #end

        #if object == nil
          #ark.destroy
        #else
          if ark.local_original_identifier_type == 'DSpace Handle'
            begin
              object = ActiveFedora::Base.find(ark.pid).adapt_to_cmodel
            rescue
              ark.destroy
            end

            if object == nil
              ark.destroy
            else
              ark.parent_pid = object.collection.pid
              ark.save!
            end


          elsif ark.local_original_identifier_type == 'TESTING'
            ark.destroy
          elsif ark.local_original_identifier_type == 'field'
            ark.local_original_identifier_type =  ark.parent_pid + ' ' + ark.local_original_identifier_type

            begin
              object = ActiveFedora::Base.find(ark.pid).adapt_to_cmodel
            rescue
              ark.destroy
            end

            if object == nil
              ark.destroy
            else
              puts ark.pid
              if object.collection == nil
                object.image_files.first.delete
                object = ActiveFedora::Base.find(ark.pid).adapt_to_cmodel
                object.delete
                ark.destroy
              else
                ark.parent_pid = object.collection.pid
                ark.save!
              end



            end

          elsif ark.local_original_identifier_type.split(' ').length > 1
            pid_part = ark.local_original_identifier_type.split(' ').first
            if pid_part.include?(':') && pid_part.length == 22
              ark.parent_pid = pid_part
              ark.local_original_identifier_type = ark.local_original_identifier_type.slice((ark.local_original_identifier_type.index(' '))+1..ark.local_original_identifier_type.length)

              #puts 'Regular Object'
              #puts ark.parent_pid
              #puts ark.local_original_identifier
              #puts ark.local_original_identifier_type
              #puts ark.pid
              ark.save!
            end

          else
            puts '------------Bad Ark---------------'
            puts ark.local_original_identifier
            puts ark.local_original_identifier_type
            puts ark.pid
          end
        #end

      end
    end
  end

  #DSPACE records?
  def self.fixToNewFormatFiles
    arks = Ark.all
    arks.each do |ark|
      if ark.model_type == 'Bplmodels::ImageFile'
        if ark.local_original_identifier_type == 'TESTING'
          begin
            object = ActiveFedora::Base.find(ark.pid).adapt_to_cmodel
            object.delete
          rescue

          end
          ark.destroy

        else
          puts 'File Object'
          puts ark.parent_pid
          puts ark.local_original_identifier
          puts ark.local_original_identifier_type

          begin
            object = ActiveFedora::Base.find(ark.pid).adapt_to_cmodel
          rescue
            ark.destroy
          end

          if object.blank?
            ark.destroy
          else
            top_level_object = object.object
            if top_level_object.blank?
              object.delete
              ark.destroy
            else
              ark.parent_pid = top_level_object.pid
              ark.local_original_identifier = top_level_object.workflowMetadata.item_source.ingest_filepath.split('/').last
              ark.local_original_identifier_type = 'File Name'
              ark.save!
            end
          end

          #ark.save!
        end
      end
    end

  end

  def self.fixFileArks

    Bplmodels::ImageFile.find_in_batches('*:*') do |group|
      group.each { |image|
        image_file = Bplmodels::ImageFile.find(image['id'])

        top_level_object = image_file.object
        if top_level_object.blank?
          image_file.workflowMetadata.marked_for_deletion = 'true'
          image_file.workflowMetadata.marked_for_deletion(0).reason = 'no top level object'
          image_file.save
        else
          top_level_object = top_level_object.adapt_to_cmodel
          dup_test = Ark.where(:pid=>image_file.pid)
          if dup_test.length < 1
            ark = Ark.new
            ark.namespace_ark = '50959'
            ark.url_base = 'https://search.digitalcommonwealth.org'
            ark.parent_pid = top_level_object.pid
            ark.pid = image_file.pid
            ark.noid = image_file.pid.split(':').last
            ark.namespace_id = image_file.pid.split(':').first
            ark.model_type = 'Bplmodels::ImageFile'
            ark.view_thumbnail = '/preview/'
            ark.view_object = '/search/'
            ark.local_original_identifier = top_level_object.workflowMetadata.item_source.ingest_filepath.split('/').last
            ark.local_original_identifier_type = 'File Name'
            ark.save
          end
        end

      }

    end


  end

  #Four extra photographic arks.
  #2000 extra file arks.
  #1000 extra non-photographic print arks.
  def self.sanityCheckObjects

    Bplmodels::SimpleObjectBase.find_in_batches('*:*') do |group|
      group.each { |image|
        object = ActiveFedora::Base.find(image['id']).adapt_to_cmodel

        top_level_object = object.collection

        if top_level_object.blank?
          object.workflowMetadata.marked_for_deletion = 'true'
          object.workflowMetadata.marked_for_deletion(0).reason = 'no top level object'
          object.save
        else
          dup_test = Ark.where(:pid=>object.pid)
          if dup_test.length < 1
            object.workflowMetadata.marked_for_deletion = 'false'
            object.workflowMetadata.marked_for_deletion(0).reason = 'ARK MISSING!!!'
            object.save
          end
        end

      }

    end
  end



  def self.sanityCheckCollections

    Bplmodels::Collection.find_in_batches('*:*') do |group|
      group.each { |image|
        collection = ActiveFedora::Base.find(image['id']).adapt_to_cmodel

        bottom_level_objects = collection.objects

        if bottom_level_objects.blank? || bottom_level_objects.size < 10
          collection.workflowMetadata.marked_for_deletion = 'true'
          collection.workflowMetadata.marked_for_deletion(0).reason = 'no bottom level objects or very few...'
          collection.save
        else
          dup_test = Ark.where(:pid=>collection.pid)
          if dup_test.length < 1
            collection.workflowMetadata.marked_for_deletion = 'false'
            collection.workflowMetadata.marked_for_deletion(0).reason = 'ARK MISSING!!!'
          end
        end

      }

    end
  end

  def self.sanityCheckObjects
    ActiveFedora::Base.find_in_batches('-is_member_of_collection_ssim'=>'[* TO *]','active_fedora_model_ssi'=>'Bplmodels::OAIObject') do |group|
      group.each { |object_id|
        puts object_id['id']
        breakhere
        #object = ActiveFedora::Base.find(object_id['id']).adapt_to_cmodel

        #top_level_object = object.collection

        #if top_level_object.blank?

          #object.delete

        #end

      }

    end
  end

  def self.removeFaulkner
    object_id_array = []

    Bplmodels::ObjectBase.find_in_batches('is_member_of_collection_ssim'=>'info:fedora/commonwealth:m613mx61z') do |collection_group|
      collection_group.each { |solr_objects|

        pid = solr_objects['id']
        object_id_array << pid

        if object_id_array != 268
          raise 'error ' + object_id_array.to_s
        end

        object_id_array.each do |object_id|
          object = Bplmodels::ObjectBase.find(object_id).adapt_to_cmodel

          ark_object = Ark.where(:pid=>object_id).first
          ark_object.destroy

          Bplmodels::File.find_in_batches('is_file_of_ssim'=>"info:fedora/#{object.pid}") do |group|
            group.each { |solr_file|
              file = Bplmodels::File.find(solr_file['id']).adapt_to_cmodel
              file.delete
              ark_object = Ark.where(:pid=>solr_file['id']).first
              ark_object.destroy
            }
          end

          object.reload
          object.delete
        end

      }
    end
  end
end