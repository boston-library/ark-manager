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


      }
    end



    if object_id_array.length != 268
      raise 'error ' + object_id_array.length.to_s + object_id_array.to_s
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

  end


  #POSSIBLE KNOWN BUG: Multiple files in item origin
  def self.updateAllObject
    new_logger = Logger.new('log/scripts_log')
    new_logger.level = Logger::ERROR

    object_id_array = []

    Bplmodels::ObjectBase.find_in_batches('has_model_ssim'=>"info:fedora/afmodel:Bplmodels_ObjectBase") do |group|
      group.each { |solr_object|
        object_id_array << solr_object['id']
      }
    end


=begin
    ActiveFedora::Base.find_in_batches("*:*") do |group|
      group.each { |solr_object|
        object_id_array << solr_object['id']
      }
    end
=end

    new_logger.error "Object array was: " + object_id_array.length.to_s

    if bject_id_array.length < 100000 || object_id_array.length > 110000
      puts 'Only a size of ' + object_id_array.length.to_s
      raise 'Not enough objects (or too many) found ' + object_id_array.length.to_s
    else
      object_id_array.each do |pid|
        new_logger.error "Processing for PID: " + pid
        puts "Processing for PID: " + pid
        main_object = ActiveFedora::Base.find(pid).adapt_to_cmodel

        #Fix test obhects....
        if main_object.class.name == "ActiveFedora::Base" || main_object.class.name == "Bplmodels::SimpleObjectBase" || main_object.class.name == "Bplmodels::ObjectBase"
            main_object = main_object.adapt_to(Bplmodels::SimpleObjectBase)

          model_type = main_object.descMetadata.genre_basic.first
          instantiate_type = Bplmodels::SimpleObjectBase
          case model_type.downcase
            when 'photographs'
              instantiate_type = Bplmodels::PhotographicPrint
            when 'prints', 'drawings', 'paintings', 'posters'
              instantiate_type = Bplmodels::NonPhotographicPrint
            when 'maps'
              instantiate_type = Bplmodels::Map
            when 'documents'
              instantiate_type = Bplmodels::Document
            when 'ephemera'
              instantiate_type = Bplmodels::Ephemera
            when 'objects'
              instantiate_type = Bplmodels::Object
            when 'periodicals'
              instantiate_type = Bplmodels::Periodical
            when 'cards'
              instantiate_type = Bplmodels::Card
            when 'manuscripts'
              instantiate_type = Bplmodels::Manuscript
            when 'albums'
              instantiate_type = Bplmodels::Scrapbook
            when 'sound recordings'
              instantiate_type = Bplmodels::SoundRecording
            when 'books'
              instantiate_type = Bplmodels::Book
            when 'newspapers'
              instantiate_type = Bplmodels::Newspaper
          end

          main_object = main_object.convert_to(instantiate_type)
          main_object.save
        end

        if main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_File") || main_object.relationships(:has_model).include?("info:fedora/fedora-system:ContentModel-3.0") || main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_Institution") || main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_Collection")



        elsif main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_OAIObject")
          #OAI Migration Stuff
          main_object.workflowMetadata.insert_oai_defaults
          ark_info = Ark.where(:pid=>pid)
          if(ark_info.length > 1)
            #LOG HERE?
            new_logger.error "More than 1 ARK found for main object " + pid
          elsif ark_info.blank?
            new_logger.error "No ARKS found for main object " + pid
          else
            ark_info = ark_info.first
            main_object.workflowMetadata.item_ark_info.ark_id = ark_info.local_original_identifier
            main_object.workflowMetadata.item_ark_info.ark_type = ark_info.local_original_identifier_type
            main_object.workflowMetadata.item_ark_info.ark_parent_pid = ark_info.parent_pid
          end

          main_object.save

        else

          ##### UPDATE ARKS #######
          ark_info = Ark.where(:pid=>pid)
          if(ark_info.length > 1)
            new_logger.error "More than 1 ARK found for main object " + pid
          elsif ark_info.blank?
            new_logger.error "No ARKS found for main object " + pid
          else
            ark_info = ark_info.first
            main_object.workflowMetadata.item_ark_info.ark_id = ark_info.local_original_identifier
            main_object.workflowMetadata.item_ark_info.ark_type = ark_info.local_original_identifier_type
            main_object.workflowMetadata.item_ark_info.ark_parent_pid = ark_info.parent_pid
          end

          ##### UPDATE WORKFLOW ####
          if main_object.workflowMetadata.source.blank?
            main_object.workflowMetadata.item_source.ingest_filepath.each do |this_file|
              main_object.workflowMetadata.insert_file_source(this_file, this_file.split('/').last, 'productionMaster')
            end

          end


          files = main_object.files
          files.each_with_index do |the_file, file_index|
            the_file = the_file.adapt_to_cmodel

            if the_file.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ImageFile")
              if the_file.accessMaster.versionable == true
                the_file.accessMaster.versionable = false
                the_file.save
              end
            end

            ark_file_info = Ark.where(:pid=>the_file.pid)

            if(ark_file_info.length > 1)
              new_logger.error "More than 1 ARK found for file object " + the_file.pid
            elsif ark_file_info.blank?
              new_logger.error "No ARKS found for file object " + the_file.pid
            else
              ark_file_info = ark_file_info.first
              # )
              if(the_file.productionMaster.label == 'productionMaster datastream'|| the_file.productionMaster.label.include?('/') || the_file.productionMaster.label.include?(' File'))
                if ark_file_info.local_original_identifier.include?('/') || ark_file_info.local_original_identifier.include?(' File')
                  main_object.workflowMetadata.item_source.ingest_filepath.each do |item_source|
                    if item_source.include?(ark_file_info.local_original_identifier.gsub(' File', ''))
                      the_file.productionMaster.dsLabel = item_source.split('/').last.gsub('.tif', '').gsub('.jpg', '').gsub('.mp3', '').gsub('.wav', '').gsub('.pdf', '').gsub('.txt', '')
                      if the_file.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ImageFile")
                        the_file.accessMaster.dsLabel = the_file.productionMaster.label
                      end
                      if the_file.thumbnail300.mimeType.present?
                        the_file.thumbnail300.dsLabel = the_file.productionMaster.label
                      end

                    end
                  end

                  if the_file.productionMaster.label == 'productionMaster datastream' && main_object.workflowMetadata.item_source.ingest_filepath.length == 1
                    the_file.productionMaster.dsLabel = main_object.workflowMetadata.item_source.ingest_filepath.first.split('/').last.gsub('.tif', '').gsub('.jpg', '').gsub('.mp3', '').gsub('.wav', '').gsub('.pdf', '').gsub('.txt', '')
                    if the_file.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ImageFile")
                      the_file.accessMaster.dsLabel = the_file.productionMaster.label
                    end
                    if the_file.thumbnail300.mimeType.present?
                      the_file.thumbnail300.dsLabel = the_file.productionMaster.label
                    end
                  end
                else
                  the_file.productionMaster.dsLabel = ark_file_info.local_original_identifier.gsub('.tif', '').gsub('.jpg', '').gsub('.mp3', '').gsub('.wav', '').gsub('.pdf', '').gsub('.txt', '')
                  if the_file.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ImageFile")
                    the_file.accessMaster.dsLabel = the_file.productionMaster.label
                  end
                  if the_file.thumbnail300.mimeType.present?
                    the_file.thumbnail300.dsLabel = the_file.productionMaster.label
                  end
                end

              else
                the_file.productionMaster.dsLabel = the_file.productionMaster.label.gsub('.tif', '').gsub('.jpg', '').gsub('.mp3', '').gsub('.wav', '')
                if the_file.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ImageFile")
                  the_file.accessMaster.dsLabel = the_file.productionMaster.label
                end
                if the_file.thumbnail300.mimeType.present?
                  the_file.thumbnail300.dsLabel = the_file.productionMaster.label
                end
              end

              if the_file.workflowMetadata.item_ark_info.blank?
                the_file.workflowMetadata.item_ark_info.ark_id = ark_file_info.local_original_identifier
                the_file.workflowMetadata.item_ark_info.ark_type = ark_file_info.local_original_identifier_type
                the_file.workflowMetadata.item_ark_info.ark_parent_pid = ark_file_info.parent_pid
              end

              if the_file.workflowMetadata.source.blank?
                main_object.workflowMetadata.item_source.ingest_filepath.each do |item_source|
                  if item_source.include?(the_file.productionMaster.label)
                    the_file.workflowMetadata.insert_file_source(item_source, item_source.split('/').last, 'productionMaster')
                  end
                end

              end
            end

            the_file.save

            #if the_file.workflowMetadata.item_status.blank?
            #the_file.workflowMetadata.item_status.state = "published"
            #the_file.workflowMetadata.item_status.state_comment = "Added metadata via update script on " + Time.new.year.to_s + "/" + Time.new.month.to_s + "/" + Time.new.day.to_s
            #end


          end

          if main_object.workflowMetadata.item_source(0).ingest_filepath.length != files.size
            new_logger.error "Note that main object didn't have a full file source tree: " + main_object.pid
          end



          all_complex_objects = []
          all_complex_objects << "info:fedora/afmodel:Bplmodels_Book"
          all_complex_objects << "info:fedora/afmodel:Bplmodels_Manuscript"
          all_complex_objects << "info:fedora/afmodel:Bplmodels_Newspaper"
          all_complex_objects << "info:fedora/afmodel:Bplmodels_Scrapbook"
          all_complex_objects << "info:fedora/afmodel:Bplmodels_SoundRecording"




          if main_object.relationships(:has_model).any? { |model| all_complex_objects.include?(model) }
            if main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_Book") && !main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ComplexObject")
              main_object = main_object.convert_to(Bplmodels::Book)
              main_object.save
            elsif main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_Manuscript") && !main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ComplexObject")
              main_object = main_object.convert_to(Bplmodels::Manuscript)
              main_object.save
            elsif main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_Newspaper") && !main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ComplexObject")
              main_object = main_object.convert_to(Bplmodels::Newspaper)
              main_object.save
            elsif main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_Scrapbook") && !main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ComplexObject")
              main_object = main_object.convert_to(Bplmodels::Scrapbook)
              main_object.save
            elsif main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_SoundRecording") && !main_object.relationships(:has_model).include?("info:fedora/afmodel:Bplmodels_ComplexObject")
              main_object = main_object.convert_to(Bplmodels::SoundRecording)
              main_object.save
            end
          end


          ##### UPDATE DERIVATIVES ####
          if main_object.workflowMetadata.item_status.processing.blank?
            main_object.workflowMetadata.item_status.processing = "derivatives"
            main_object.workflowMetadata.item_status.processing_comment = "Awaiting Derivative Creation"
            main_object.save
            main_object.derivative_service("true")
          end

          main_object.save


        end
      end

    end




  end
end