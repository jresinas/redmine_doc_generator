class OdsManager
	# Carga una hoja de calculo a partir de una plantilla
  def self.load(template, filename)
    file_route = "tmp/"+filename+".ods"

  	#Copiamos el fichero plantilla a la carpeta /tmp
    FileUtils.cp(template, file_route)

    # Cargamos el fichero
    sheet=Rods.new(file_route)

    return sheet
  end

  # Fusiona varias celdas en una fila
  def self.merge_cells(sheet,row,init_col,num_col)
  	cell = sheet.getCell(row,init_col)
  	cell.attributes["table:number-columns-spanned"] = num_col

  	return sheet
  end

  # Devuelve el estilo de una celda
  def self.get_style(sheet, rowcell, column=nil)
  	if column!=nil
  		cell = sheet.getCell(rowcell,column)
  		return cell.attributes["table:style-name"]
  	else
  		return rowcell.attributes["table:style-name"]
  	end
  end

  # Escribe en una celda forzando la conservación del estilo y fusión de celdas contiguas (en fila)
  def self.write_cell(sheet, row, col, type, text)
    cell = sheet.getCell(row,col)

    style = cell.attributes["table:style-name"]
    merged_cells = cell.attributes["table:number-columns-spanned"]

    sheet.writeCell(row,col,type,text)

    if style!=nil
      cell.attributes["table:style-name"] = style
    end

    if merged_cells
      cell.attributes["table:number-columns-spanned"] = merged_cells
    end
  end

  # Inserta valores de un array bidimensional en un area rectangular de la hoja de calculo, conservando el estilo de la celda inicial y las fusiones de celda de cada columna en la primera fila
  def self.insert_table_rows(sheet, values, init_row, init_col, end_row, end_col)
    cell = sheet.getCell(init_row,init_col)
    style = cell.attributes["table:style-name"]

    # Generamos array con el número de columnas fusionadas en cada celda de la primera fila
    offset = 0
    init_row_merge = Array.new
    for col in init_col..end_col
      # Offset representa el número de columnas que debemos saltarnos debido a las fusiones de celdas que se hayan realizado 
      if col <= end_col-offset
        cell = sheet.getCell(init_row,col)
        merge = cell.attributes["table:number-columns-spanned"]
        init_row_merge << merge

        # Si hay fusión de celdas, incrementamos el offset
        if merge!=nil
          offset = offset + merge.to_i - 1
        end

        # Por alguna razon, al obtener "merge" algunas celdas pierden su estilo. Con esta linea se les reestablece
        cell.attributes["table:style-name"] = style
      end
    end

    offset=0
    i = 0
    j = 0
    for row in init_row..end_row
      if (values.length-1 >= i)
        sheet.insertRow(row)
        offset = 0
        j = 0
        for col in init_col..end_col
          # Si quedan valores por escribir en la fila, lo escribimos
          if (values[i].length-1 >= j)
            sheet.writeCell(row,col+offset,'string',values[i][j])
          end
          # Establecemos el estilo de la celda
          sheet.setStyle(sheet.getCell(row,col),style)
          # Si hay columnas fusionadas la aplicamos e incrementamos el offset para escribir correctamente las siguients celdas de la fila
          if init_row_merge[j]!=nil
            OdsManager.merge_cells(sheet,row,col+offset,init_row_merge[j])
            offset = offset + init_row_merge[j].to_i - 1
          end
          j = j + 1
        end
      end
      i = i + 1
    end
  end




  def self.set_values(sheet, values, init_row, init_col, end_row, end_col)
    i = 0

    for col in init_col..end_col
      for row in init_row..end_row
        sheet.writeCell(row,col,'string',values[i])
        i = i+1
      end
    end
  end











#Funciona
  def self.insert_table_rows2(sheet, values, init_row, init_col, end_row, end_col)
    cell = sheet.getCell(init_row,init_col)
    style = cell.attributes["table:style-name"]

    i = 0
    j = 0
    for row in init_row..end_row
      if (values.length-1 >= i)
        sheet.insertRow(row)
        j = 0
        for col in init_col..end_col
          if (values[i].length-1 >= j)
            sheet.writeCell(row,col,'string',values[i][j])
          end
          sheet.setStyle(sheet.getCell(row,col),style)
          j = j + 1
        end
      end
      i = i + 1
    end
  end

# Toma el estilo de la columna correspondiente en la primera fila. Por algun motivo, algunas columnas no muestran estilo
  def self.insert_table_rows_ideal(sheet, values, init_row, init_col, end_row, end_col)
    init_row_style = Array.new
    for col in init_col..end_col
      cell = sheet.getCell(init_row,col)
      style = cell.attributes["table:style-name"]
      init_row_style << style
    end


    i = 0
    j = 0
		for row in init_row..end_row
      if (values.length-1 >= i)
        sheet.insertRow(row)
        j = 0
    		for col in init_col..end_col
          if (values[i].length-1 >= j)
    		    sheet.writeCell(row,col,'string',values[i][j])
#            OdsManager.write_cell(sheet,row,col,'string',values[i][j])
          end
          sheet.setStyle(sheet.getCell(row,col),init_row_style[j])
          j = j + 1
    		end
      end
      i = i + 1
  	end
  end
end