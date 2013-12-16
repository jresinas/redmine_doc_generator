class GeneratorsController < ApplicationController
  unloadable

  def project_plan
    project = Project.find(params[:project_id])
    expediente = project.name

    # Obtenemos el último expediente asociado al proyecto para mostrarlo en el nombre del fichero que se va a generar
    expediente = DocGenerator.get_project_expedient(params[:project_id])

    # Creamos el nuevo fichero a partir de la plantilla seleccionada en la configuración del plugin
    template = 'plugins/redmine_doc_generator/templates/'+Setting.plugin_redmine_doc_generator['pp_template_dir']
    filename = 'pp_prueba'+Time.now.to_i.to_s
    sheet = OdsManager.load(template,filename)

    # Generamos el contenido de las distintas pestañas del fichero
    DocGenerator.pp_plan_configuracion(sheet,params[:project_id])
    DocGenerator.pp_recursos_tecnicos(sheet,params[:project_id])
    DocGenerator.pp_rrhh(sheet,params[:project_id])
    DocGenerator.pp_general(sheet,params[:project_id])

    # Guardamos el fichero y lo enviamos al usuario
    sheet.save()
    send_file 'tmp/'+filename+'.ods' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Plan_Proyecto.ods'
  end

  def aims_catalog
    template = "plugins/redmine_doc_generator/templates/"+Setting.plugin_redmine_doc_generator['co_template_dir']
    filename = "co_prueba"+Time.now.to_i.to_s

    # Obtenemos el id del tracker "Objetivo"
    objetivo_id = Tracker.find_by_name('Objetivos').id

    # Obtenemos el último expediente asociado al proyecto para mostrarlo en el nombre del fichero que se va a generar
    expediente = DocGenerator.get_project_expedient(params[:project_id])

    # Obtenemos lista de ids a analizar: el propio proyecto y sus hijos
    project_ids = DocGenerator.get_project_and_related_project_ids(params[:project_id])

    # Obtenemos las tareas asociadas a los proyectos a analizar
    issues = Issue.find_all_by_project_id_and_tracker_id(project_ids,objetivo_id)

    # Generamos y procesamos el documento de texto y lo enviamos al usuario
    report = ODFReport::Report.new(template) do |r|
      DocGenerator.aims_catalog(r, params[:project_id], issues)
    end
    report.generate("tmp/"+filename+".odt")
    send_file 'tmp/'+filename+'.odt' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Catalogo_Objetivos.odt'
  end

  def functional_analysis
    template = "plugins/redmine_doc_generator/templates/"+Setting.plugin_redmine_doc_generator['af_template_dir']
    filename = "af_prueba"+Time.now.to_i.to_s

    # Obtenemos los id de los trackers "Requisitos" y "Casos de uso" y del campo personalizado "Categoría"
    requisito_id = Tracker.find_by_name('Requisitos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id
    tipo_requisito_id = CustomField.find_by_name('Tipo de requisito').id

    # Obtenemos el último expediente asociado al proyecto para mostrarlo en el nombre del fichero que se va a generar
    expediente = DocGenerator.get_project_expedient(params[:project_id])

    # Obtenemos lista de ids a analizar: el propio proyecto y sus hijos
    project_ids = DocGenerator.get_project_and_related_project_ids(params[:project_id])

    # Obtenemos los requisitos de actores, funcionales, de información y no funcionales (en estos últimos introducimos cualquier otro tipo de requisito no especificado en los grupos anteriores)
    actors = Array.new
    func_req = Array.new
    no_func_req = Array.new
    info_req = Array.new

    requirements = Issue.find_all_by_project_id_and_tracker_id(project_ids,requisito_id)

    requirements.each do |requirement|
      requirement_type = CustomValue.find_by_customized_id_and_custom_field_id(requirement.id, tipo_requisito_id)
      if requirement_type.present?
        case requirement_type.value
          when "De Actor"
            actors << requirement
          when "Funcional"
            func_req << requirement
          when "De Información"
            info_req << requirement
          else #when "No funcional"
            no_func_req << requirement
        end
      end
    end

    # Obtenemos los casos de uso
    use_cases = Issue.find_all_by_project_id_and_tracker_id(project_ids,caso_uso_id)

    # Generamos y procesamos el documento de texto y lo enviamos al usuario
    report = ODFReport::Report.new(template) do |r|
      DocGenerator.functional_analysis_actors(r, params[:project_id], actors)
      DocGenerator.functional_analysis_use_cases(r, params[:project_id], use_cases)
      DocGenerator.functional_analysis_functional_requirements(r, params[:project_id], func_req)
      DocGenerator.functional_analysis_non_functional_requirements(r, params[:project_id], no_func_req)
      DocGenerator.functional_analysis_information_requirements(r, params[:project_id], info_req)
    end
    report.generate("tmp/"+filename+".odt")
    send_file 'tmp/'+filename+'.odt' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Analisis_Funcional.odt'
  end  

  def test_cases
    template = "plugins/redmine_doc_generator/templates/"+Setting.plugin_redmine_doc_generator['cp_template_dir']
    filename = "cp_prueba"+Time.now.to_i.to_s

    caso_prueba_id = Tracker.find_by_name('Casos de prueba').id
    tipo_prueba_id = CustomField.find_by_name('Tipos de Pruebas').id

    # Obtenemos el último expediente asociado al proyecto para mostrarlo en el nombre del fichero que se va a generar
    expediente = DocGenerator.get_project_expedient(params[:project_id])

    # Obtenemos lista de ids a analizar: el propio proyecto y sus hijos
    project_ids = DocGenerator.get_project_and_related_project_ids(params[:project_id])

    # Obtenemos los requisitos de actores, funcionales, no funcionales y de información
    func_test = Array.new
    unity_test = Array.new
    system_test = Array.new
    performance_test = Array.new
    static_test = Array.new

    tests = Issue.find_all_by_project_id_and_tracker_id(project_ids,caso_prueba_id)

    tests.each do |test|
      test_type = CustomValue.find_by_customized_id_and_custom_field_id(test.id, tipo_prueba_id)
      if test_type.present?
        case test_type.value
          when "Funcionales"
            func_test << test
          when "Unitarias"
            unity_test << test
          when "Sistema"
            system_test << test
          when "Rendimiento"
            performance_test << test
          when "Estáticas"
            static_test << test
        end
      end
    end

    # Generamos y procesamos el documento de texto y lo enviamos al usuario
    report = ODFReport::Report.new(template) do |r|
      r.add_field :functional_analysis_doc_name, 'P_PRO-'+expediente+'-Analisis_Funcional.odt'
      DocGenerator.test_case_pf(r, params[:project_id], func_test)
      DocGenerator.test_case_pu(r, params[:project_id], unity_test)
      DocGenerator.test_case_ps(r, params[:project_id], system_test)
      DocGenerator.test_case_pr(r, params[:project_id], performance_test)
      DocGenerator.test_case_pe(r, params[:project_id], static_test)
    end
    report.generate("tmp/"+filename+".odt")
    send_file 'tmp/'+filename+'.odt' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Plan_Pruebas.odt'
  end
end
