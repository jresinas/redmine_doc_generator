class DocTexts
	def self.aims_catalog(r, project_id, issues)
		# Obtenemos el id del campo personalizado "Código"
		codigo_id = CustomField.find_by_name('Código').id

		# Obtenemos le nombre del proyecto
		project = Project.find_by_id(project_id)
    project_title = project.name

    # Ponemos el titulo del proyecto en la primera página
    r.add_field :proy_titulo, project_title 

    # Si no habían tareas de tipo "Objetivo", imprimimos la tabla de ejemplo
    if issues.empty?
      r.add_field :obj_cod, 'OB-00X'
      r.add_field :obj_titulo, 'Título del objetivo.'
      r.add_field :obj_desc, 'Descripción del objetivo.'
#      r.add_field :obj_index, 1
    # Si no, creamos una tabla y su comentario para cada tarea de tipo "Objetivo"
    else
      r.add_section("Sección1", issues) do |s|
        s.add_field(:obj_cod) {|issue| CustomValue.find_all_by_customized_id_and_custom_field_id(issue.id, codigo_id)}
        s.add_field :obj_titulo, :subject
        s.add_field(:obj_desc) {|issue| DocTexts.parsing_wiki_text(issue.description)}
#        s.add_field(:obj_index) {|issue| issues.index(issue)+1}
      end
    end
	end

	def self.functional_analysis_actors(r, project_id, actors)
		# Obtenemos el id del campo personalizado "Código"
		codigo_id = CustomField.find_by_name('Código').id

		# Si no habían requisitos de actores, imprimimos la tabla de ejemplo
    if actors.empty?
      r.add_field :act_cod, 'AC-00X'
      r.add_field :act_nombre, 'Nombre del Actor.'
      r.add_field :act_desc, 'Descripción del Actor.'
      r.add_field :act_coment, 'Comentario con información adicional.'
#      r.add_field :act_index, 1
    # Si no, creamos una tabla y su comentario para cada requisito de actor
    else
      r.add_section("SecciónActor", actors) do |s|
        s.add_field(:act_cod) {|actor| CustomValue.find_all_by_customized_id_and_custom_field_id(actor.id, codigo_id)}
        s.add_field :act_nombre, :subject
        s.add_field(:act_desc) {|actor| DocTexts.parsing_wiki_text(actor.description)}
        s.add_field(:act_coment) {|actor| ""}
#        s.add_field(:act_index) {|actor| actors.index(actor)+1}
      end
    end
	end

	def self.functional_analysis_use_cases(r, project_id, use_cases)
		# Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
		requisito_id = Tracker.find_by_name('Requisitos').id
		objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

		# Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
		codigo_id = CustomField.find_by_name('Código').id
    pre_id = CustomField.find_by_name('Precondición').id
		secuencia_id = CustomField.find_by_name('Secuencia normal').id
		post_id = CustomField.find_by_name('Postcondición').id
    excepciones_id = CustomField.find_by_name('Excepciones').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    use_cases = DocTexts.get_related_issues(use_cases, [requisito_id, caso_uso_id, objetivo_id], true)

		# Si no habían requisitos de actores, imprimimos la tabla de ejemplo
    if use_cases.empty?
      s.add_field :cu_cod, "CU-00X"
      s.add_field :cu_titulo, "Título del caso de uso."
      s.add_field :cu_desc, "Descripción del caso de uso."
      s.add_field :cu_actores, "Actores que intervienen en el caso de uso."
      s.add_field :cu_relacion, "Relaciones del caso de uso: objetivos, otros casos de uso, requisitos."
      s.add_field :cu_pre, "Condición de necesario cumplimiento antes de producirse el caso de uso."
      s.add_field :cu_secuencia, "Título de casuística 1\n1. Paso 1\n2. Paso 2\nN. Paso N\n\nTítulo de casuística 2\n1. Paso 1\n2. Paso 2\nN. Paso N"
      s.add_field :cu_excepciones, "Excepciones"
#      s.add_field(:cu_index) {|use_case| use_cases.index(use_case)+1}
    # Si no, creamos una tabla y su comentario para cada requisito de actor
    else
      r.add_section("SecciónCU", use_cases) do |s|
        s.add_field(:cu_cod) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, codigo_id)}
        s.add_field :cu_titulo, :subject
        s.add_field(:cu_desc) {|use_case| DocTexts.parsing_wiki_text(use_case.description)}
        s.add_section("SecciónCU_Actor", :i_actors) do |a|
          a.add_field(:cu_actor, :value)
        end
        s.add_section("SecciónCU_Relación", :i_relations) do |r|
          r.add_field(:cu_relacion, :value)
        end
        s.add_field(:cu_pre) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, pre_id)}
        s.add_field(:cu_secuencia) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, secuencia_id)}
        s.add_field(:cu_post) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, post_id)}
        s.add_field(:cu_excepciones) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, excepciones_id)}
#        s.add_field(:cu_index) {|use_case| use_cases.index(use_case)+1}
      end
    end
	end

  def self.functional_analysis_functional_requirements(r, project_id, func_req)
    # Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
    codigo_id = CustomField.find_by_name('Código').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    func_req = DocTexts.get_related_issues(func_req, [requisito_id, caso_uso_id, objetivo_id], true)

    # Si no habían requisitos de actores, imprimimos la tabla de ejemplo
    if func_req.empty?
      s.add_field :rf_cod, "RF-00X"
      s.add_field :rf_titulo, "Título del requisito funcional."
      s.add_field :rf_desc, "Descripción del requisito con lenguaje natural, basado en patrones linguisticos simples."
      s.add_field :rf_actores, ""
      s.add_field :rf_relacion, ""
    # Si no, creamos una tabla y su comentario para cada requisito de actor
    else
      r.add_section("SecciónRF", func_req) do |s|
        s.add_field(:rf_cod) {|req| CustomValue.find_all_by_customized_id_and_custom_field_id(req.id, codigo_id)}
        s.add_field :rf_titulo, :subject
        s.add_field(:rf_desc) {|req| DocTexts.parsing_wiki_text(req.description)}
        s.add_section("SecciónRF_Actor", :i_actors) do |a|
          a.add_field(:rf_actor, :value)
        end
        s.add_section("SecciónRF_Relación", :i_relations) do |r|
          r.add_field(:rf_relacion, :value)
        end
      end
    end
  end

  def self.functional_analysis_non_functional_requirements(r, project_id, no_func_req)
    # Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
    codigo_id = CustomField.find_by_name('Código').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    no_func_req = DocTexts.get_related_issues(no_func_req, [requisito_id, caso_uso_id, objetivo_id], false)

    # Si no habían requisitos de actores, imprimimos la tabla de ejemplo
    if no_func_req.empty?
      s.add_field :rnf_cod, "RNF-00X"
      s.add_field :rnf_titulo, "Título del requisito no funcional."
      s.add_field :rnf_desc, "Descripción breve del requisito, en lenguaje natural y sin entrar en demasiado detalle técnico."
      s.add_field :rnf_relacion, "Otros requisitos, casos de uso y objetivos relacionados con el requisito no funcional."
      s.add_field :rnf_prioridad, "Prioridad de cumplimiento de dicho requisito."
    # Si no, creamos una tabla y su comentario para cada requisito de actor
    else
      r.add_section("SecciónRNF", no_func_req) do |s|
        s.add_field(:rnf_cod) {|req| CustomValue.find_all_by_customized_id_and_custom_field_id(req.id, codigo_id)}
        s.add_field :rnf_titulo, :subject
        s.add_field(:rnf_desc) {|req| DocTexts.parsing_wiki_text(req.description)}
        s.add_section("SecciónRNF_Relación", :i_relations) do |r|
          r.add_field(:rnf_relacion, :value)
        end
        s.add_field(:rnf_prioridad) {|req| req.priority.name}
      end
    end
  end


  def self.functional_analysis_information_requirements(r, project_id, info_req)
    # Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
    codigo_id = CustomField.find_by_name('Código').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    info_req = DocTexts.get_related_issues(info_req, [requisito_id, caso_uso_id, objetivo_id], false)

    # Si no habían requisitos de actores, imprimimos la tabla de ejemplo
    if info_req.empty?
      s.add_field :ri_cod, "RI-00X"
      s.add_field :ri_titulo, "Título del Requisito de Información."
      s.add_field :ri_desc, "Descripción del Requisito de Información."
      s.add_field :ri_relacion, "Objetivos, Casos de Uso, y otros Requisitos Funcionales, No Funcionales y de información relacionados con el requisito de información en cuestión."
      s.add_field :ri_prioridad, "Prioridad del requisito de información, para indicar su especial tratamiento en el diseño del modelo de datos posterior."
    # Si no, creamos una tabla y su comentario para cada requisito de actor
    else
      r.add_section("SecciónRI", info_req) do |s|
        s.add_field(:ri_cod) {|req| CustomValue.find_all_by_customized_id_and_custom_field_id(req.id, codigo_id)}
        s.add_field :ri_titulo, :subject
        s.add_field(:ri_desc) {|req| DocTexts.parsing_wiki_text(req.description)}
        s.add_section("SecciónRI_Relación", :i_relations) do |r|
          r.add_field(:ri_relacion, :value)
        end
        s.add_field(:ri_prioridad) {|req| req.priority.name}
      end
    end
  end



  def self.functional_analysis_traceability_matrix(r, project_id, use_cases)


    r.add_table("TableMT", use_cases) do |t|
      t.add_column(:id)
    end
  end




  # Modifica la estructura de un array de peticiones para añadir una sección con las peticiones y actores relacionados
  # issues es la lista de peticiones sobre la que se quieren buscar sus peticiones relacionadas
  # trackers consiste en un array con los identificadores de los distintos trackers que se consideran para las relaciones
  # actors consiste en un booleano que indica si se filtra entre relaciones y actores o solo relaciones
  def self.get_related_issues(issues, trackers, actors)
    requisito_id = Tracker.find_by_name('Requisitos').id
    tipo_requisito_id = CustomField.find_by_name('Tipo de requisito').id
    codigo_id = CustomField.find_by_name('Código').id

    issues.each do |iss|
      i_actors = Array.new
      i_relations = Array.new

      # Recorremos las peticiones relacionadas con la petición actual
      iss.relations_from.each do |related|
        issue = Issue.find(related.issue_to_id)
        # Si esta activada la busqueda de actores y la petición relacionada es un requisito de tipo actor, lo incluimos en el array "i_actors"
        if actors && issue.tracker_id == requisito_id && CustomValue.find_by_customized_id_and_custom_field_id(issue.id, tipo_requisito_id).value == "De Actor"
          i_actors << CustomValue.find_by_customized_id_and_custom_field_id(issue.id, codigo_id)
        # Si la petición relacionada pertenece a uno de los trackers entre los que estamos buscando, lo incluimos en el array "i_relations"
        elsif trackers.include?(issue.tracker_id)
          i_relations << CustomValue.find_by_customized_id_and_custom_field_id(issue.id, codigo_id)
        end
      end

      # Añadimos los subarrays al elemento del array de peticiones
      iss['i_relations'] = i_relations
      iss['i_actors'] = i_actors
    end

    return issues
  end


  def self.parsing_wiki_text(text)
    text = text.gsub(/([\s\r\n])\*([^\s\r\n][^\r\n]*[^\s\r\n])\*([\s\r\n])/) {$1+$2+$3}
    text = text.gsub(/([\s\r\n])_([^\s\r\n][^\r\n]*[^\s\r\n])_([\s\r\n])/) {$1+$2+$3}
    text = text.gsub(/([\s\r\n])\+([^\s\r\n][^\r\n]*[^\s\r\n])\+([\s\r\n])/) {$1+$2+$3}
    text = text.gsub(/([\s\r\n])-([^\s\r\n][^\r\n]*[^\s\r\n])-([\s\r\n])/) {""}
    text = text.gsub(/([\s\r\n])\?\?([^\s\r\n][^\r\n]*[^\s\r\n])\?\?([\s\r\n])/) {$1+$2+$3}
    text = text.gsub(/([\s\r\n])@([^\s\r\n][^\r\n]*[^\s\r\n])@([\s\r\n])/) {$1+$2+$3}
    text = text.gsub(/\<pre\>(.+?)\<\/pre\>/) {"\r\n"+$1+"\r\n"}
#    text = text.gsub(/(\r\n\r\n|\n\n|\r\r)h[1-6]\. (.+?)(\r\n\r\n|\n\n|\r\r|\Z)/) {$1+$2+$3}
    text = text.gsub(/^h[1-6]\. /) {$1}
    text = text.gsub(/^\>(.*)$/) {"\t\t"+$1}
  end
end

# /(^[^\d].*[^\s])[\s]*/		Detecta el titulo de cada seccion de la secuencia normal. En $1 esta el titulo