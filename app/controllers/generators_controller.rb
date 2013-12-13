class GeneratorsController < ApplicationController
  unloadable

  def functional_analysis
  end

  def aims_catalog
  end

  def test_cases
  end

  def project_plan
    project = Project.find(params[:project_id])
    expediente = project.name

    # Obtenemos el último expediente asociado al proyecto para mostrarlo en el nombre del fichero que se va a generar
    project.visible_custom_field_values.each do |element|
      if element.custom_field.name == "Expediente"
        element.value.gsub(", ",",")
        arr = element.value.split(",")
        expediente = arr[arr.length-1]
      end
    end

    # Creamos el nuevo fichero a partir de la plantilla seleccionada en la configuración del plugin
    template = 'plugins/redmine_doc_generator/templates/'+Setting.plugin_redmine_doc_generator['pp_template_dir']
    filename = 'pp_prueba'
    sheet = OdsManager.load(template,filename)

    # Generamos el contenido de las distintas pestañas del fichero
    DocSheets.pp_general(sheet,params[:project_id])
    DocSheets.pp_rrhh(sheet,params[:project_id])
    DocSheets.pp_recursos_tecnicos(sheet,params[:project_id])
    DocSheets.pp_plan_configuracion(sheet,params[:project_id])

    # Guardamos el fichero y lo enviamos al usuario
    sheet.save()
    send_file 'tmp/'+filename+'.ods' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Plan_Proyecto.ods'
  end


  def prueba
#    require 'rods'
        puts "@@@@@@@@Abierto!!!"

 #   mySheet=Rods.new("prueba.ods")

 #   mySheet.save();
#    	require 'odf/spreadsheet'

#ODF::Spreadsheet.file("simple_spreadsheet.ods") do
#  table 'My first table from Ruby' do
#    row {cell 'Hello, rODF world!' }
#  end
#end
  end

  def functional_analysis
    template = "plugins/redmine_doc_generator/templates/"+Setting.plugin_redmine_doc_generator['af_template_dir']
    filename = "af_prueba"

    # Obtenemos los id de los trackers "Requisitos" y "Casos de uso" y del campo personalizado "Categoría"
    requisito_id = Tracker.find_by_name('Requisitos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id
    tipo_requisito_id = CustomField.find_by_name('Tipo de requisito').id

    # Obtenemos el último expediente asociado al proyecto para mostrarlo en el nombre del fichero que se va a generar
    project = Project.find_by_id(params[:project_id])
    expediente = project.name

    project.visible_custom_field_values.each do |element|
      if element.custom_field.name == "Expediente"
        element.value.gsub(", ",",")
        arr = element.value.split(",")
        expediente = arr[arr.length-1]
      end
    end

    # Obtenemos lista de ids a analizar: el propio proyecto y sus hijos
    project_ids = Array.new
    project_ids << params[:project_id]
    child_projects_id = Project.find_all_by_parent_id(params[:project_id])
    project_ids = (project_ids << child_projects_id).flatten

    # Obtenemos los requisitos de actores, funcionales, no funcionales y de información
    actors = Array.new
    func_req = Array.new
    no_func_req = Array.new
    info_req = Array.new

    requirements = Issue.find_all_by_project_id_and_tracker_id(project_ids,requisito_id)

    requirements.each do |requirement|
      if CustomValue.find_by_customized_id_and_custom_field_id(requirement.id, tipo_requisito_id).value == "De Actor"
        actors << requirement
      elsif CustomValue.find_by_customized_id_and_custom_field_id(requirement.id, tipo_requisito_id).value == "Funcional"
        func_req << requirement
      elsif CustomValue.find_by_customized_id_and_custom_field_id(requirement.id, tipo_requisito_id).value == "No funcional"
        no_func_req << requirement
      elsif CustomValue.find_by_customized_id_and_custom_field_id(requirement.id, tipo_requisito_id).value == "De Información"
        info_req << requirement
      end
    end

    # Obtenemos los casos de uso
    use_cases = Issue.find_all_by_project_id_and_tracker_id(project_ids,caso_uso_id)

    # Generamos y procesamos el documento de texto y lo enviamos al usuario
    report = ODFReport::Report.new(template) do |r|
      DocTexts.functional_analysis_actors(r, params[:project_id], actors)
      DocTexts.functional_analysis_use_cases(r, params[:project_id], use_cases)
      DocTexts.functional_analysis_functional_requirements(r, params[:project_id], func_req)
      DocTexts.functional_analysis_non_functional_requirements(r, params[:project_id], no_func_req)
      DocTexts.functional_analysis_information_requirements(r, params[:project_id], info_req)
#      DocTexts.functional_analysis_traceability_matrix(r, params[:project_id], use_cases)
    end
    report.generate("tmp/"+filename+".odt")
    send_file 'tmp/'+filename+'.odt' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Analisis_Funcional.odt'
  end

  def aims_catalog
    template = "plugins/redmine_doc_generator/templates/"+Setting.plugin_redmine_doc_generator['co_template_dir']
    filename = "co_prueba"

    # Obtenemos el id del tracker "Objetivo"
    objetivo_id = Tracker.find_by_name('Objetivos').id

    # Obtenemos el último expediente asociado al proyecto para mostrarlo en el nombre del fichero que se va a generar
    project = Project.find_by_id(params[:project_id])
    expediente = project.name

    project.visible_custom_field_values.each do |element|
      if element.custom_field.name == "Expediente"
        element.value.gsub(", ",",")
        arr = element.value.split(",")
        expediente = arr[arr.length-1]
      end
    end

    # Obtenemos lista de ids a analizar: el propio proyecto y sus hijos
    project_ids = Array.new
    project_ids << params[:project_id]
    child_projects_id = Project.find_all_by_parent_id(params[:project_id])
    project_ids = (project_ids << child_projects_id).flatten

    # Obtenemos las tareas asociadas a los proyectos a analizar
    issues = Issue.find_all_by_project_id_and_tracker_id(project_ids,objetivo_id)

    # Generamos y procesamos el documento de texto y lo enviamos al usuario
    report = ODFReport::Report.new(template) do |r|
      DocTexts.aims_catalog(r, params[:project_id], issues)
    end
    report.generate("tmp/"+filename+".odt")
    send_file 'tmp/'+filename+'.odt' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Catalogo_Objetivos.odt'
  end

  def self.test_cases()
  end










  def prueba2
    @sublist = Hash.new
    @sublist['attr1'] = 0
    @sublist['attr2'] = 1
    @sublist['attr3'] = 2
    @sublist['attr4'] = 3

    @list_of_items = Array.new
    @list_of_items << @sublist
    @list_of_items << @sublist
    @list_of_items << @sublist
    @list_of_items << @sublist
    @list_of_items << @sublist

    @secciones = Hash.new
    @secciones['table1'] = @list_of_elements
    @secc = {'table1' => @list_of_elements}

    projects = Project.find(:all) 
    project = Project.find(params[:project_id])
    projects2 = Array.new
    projects2 << project

logger.info project.inspect
    report = ODFReport::Report.new("/home/jresinas/Documentos/odt/plantilla.odt") do |r|
 #     r.add_field :user_name, projects2. #"Usuario"
    
      r.add_section("Sección1", projects2) do |s|
        r.add_field :project_title, project.name

        s.add_table("Tabla1", :members, :header=>true) do |t|
          t.add_column(:item_dos, :name)
   #     t.add_column(:item_id, :id)
   #     t.add_column(:description) do { |item| "==> #{item.description}" }
        end
      end
    end

    report.generate("/home/jresinas/Documentos/odt/plantilla2.odt")

#    send_file '/home/jresinas/Documentos/odt/plantilla2.odt', :x_sendfile => true
  end
end
