class BackgroundProcess
  @queue = :ark_generic_background_process

  def self.perform(*args)
    new_logger = Logger.new('log/scripts_log')
    new_logger.level = Logger::ERROR

    args = args.first

    pid = args["object_pid"]

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

          #NEW SECTION TO FIX BAD ARKS
          if ark_file_info.local_original_identifier.match(/^\-\-\-/)
            ark_file_info.local_original_identifier = ark_file_info.local_original_identifier.gsub(/\-\-\-\n\-/, '').gsub('---', '').gsub('--', '').gsub(/\n\-/, '').gsub(/\n/, '').strip
            ark_file_info.save
          end



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

          if the_file.workflowMetadata.item_ark_info.blank? || (the_file.workflowMetadata.item_ark_info(0).present? && the_file.workflowMetadata.item_ark_info(0).ark_id[0].match(/^\-\-\-/))
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

          if the_file.label.match(/ File$/)
            if ark_file_info.local_original_identifier.match(/\....$/) || ark_file_info.local_original_identifier.match(/\.....$/) || ark_file_info.local_original_identifier.match(/\...$/)
              the_file.label = ark_file_info.local_original_identifier.split('/').last
            elsif the_file.workflowMetadata.source.ingest_filename.present?
              0.upto the_file.workflowMetadata.source.length-1 do |index|

                if the_file.workflowMetadata.source(index).ingest_datastream[0] == 'productionMaster'
                  the_file.label = the_file.workflowMetadata.source(index).ingest_filename[0]
                end
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
      if main_object.workflowMetadata.item_status.processing.blank? || main_object.workflowMetadata.item_status.processing[0] == "derivatives"
        main_object.workflowMetadata.item_status.processing = "derivatives"
        main_object.workflowMetadata.item_status.processing_comment = "Awaiting Derivative Creation"
        main_object.save
        main_object.derivative_service("true")
      end

      main_object.save


    end

  end
end