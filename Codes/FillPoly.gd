extends Area2D
var pontosClique = []
var polys = []
var cor : Color = Color.YELLOW
var corfill : Color = Color.AQUA
var AreaDesenho: bool
var i = 0
func _ready() -> void:
	queue_redraw()
func _input(event):
	if event.is_action_pressed("CriarPonto") and AreaDesenho:
		criarPontos()
func criarPolys():
	polys.append({"pontos": pontosClique.duplicate(), "coraresta": cor, "cordentro": corfill})
	pontosClique = []
	queue_redraw()
func criarPontos():
	var mouse_pos = get_local_mouse_position()
	pontosClique.append(mouse_pos)
	queue_redraw()
func FillPoly(poligono):
	var ymin = null
	var ymax = null
	var points = poligono["pontos"]
	
	if points.size() < 3:
		return

	for point in points:
		if ymin == null or point.y < ymin:
			ymin = point.y
		if ymax == null or point.y > ymax:
			ymax = point.y
	
	if ymin == null or ymax == null:
		return # Retorna se não houver pontos válidos
		
	ymin = floori(ymin)
	ymax = ceili(ymax)
	
	var NsTotal = ymax - ymin
	if NsTotal <= 0:
		return # Não há altura para preencher

	var intersec: Array[Array]
	intersec.resize(NsTotal)

	# Itera por todas as arestas do polígono
	for i in range(len(points)):
		var p1 = points[i]
		var p2 = points[i-1] # GDScript lida com i-1 quando i=0, pegando o último elemento
		# Essas 2 variáveis vão garantir que comece de cima para baixo
		var start_point = p1 if p1.y < p2.y else p2
		var end_point = p1 if p1.y >= p2.y else p2

		var dx = end_point.x - start_point.x
		var dy = end_point.y - start_point.y
		if dy != 0:
			var tx = dx / dy
			var x = start_point.x

			for u in range(floori(start_point.y), floori(end_point.y)):
				var scanline_index = u - ymin
				
				# Verificação de segurança para não acessar fora do array
				if scanline_index >= 0 and scanline_index < NsTotal:
					intersec[scanline_index].append(x)
				
				x += tx # Calcula o X para a próxima scanline [cite: 125]

	var contadorLinha = 0
	for scanline in intersec:
		contadorLinha += 1
		scanline.sort()
		
		for j in range(0, len(scanline), 2):
			if j + 1 < len(scanline):
				var start_x = scanline[j]
				var end_x = scanline[j+1]
				
				if start_x != end_x:
					var line_start = Vector2(ceilf(start_x), contadorLinha + ymin)
					var line_end = Vector2(floorf(end_x), contadorLinha + ymin)
					draw_line(line_start, line_end, poligono["cordentro"])

#Função própria da Godot, para poder desenhar usando o Canvas
func _draw():
	for i in range(len(pontosClique)-1):
		draw_line(pontosClique[i], pontosClique[i + 1], cor, 3.5)
	if len(pontosClique) > 1:
		draw_line(pontosClique[-1], pontosClique[0], cor, 3.5)
	for point in pontosClique:
		draw_circle(point, 5, Color.BLACK)
	for polig in polys:
		var points = polig["pontos"]
		var corar = polig["coraresta"]
		var cordentro = polig["cordentro"]
		FillPoly(polig)
		for i in range(len(points)-1):
			draw_line(points[i], points[i + 1], corar, 3.5)
		if len(points) > 1:
			draw_line(points[-1], points[0], corar, 3.5)
		for point in points:
			draw_circle(point, 5, Color.BLACK)

func _process(delta):
	pass
	
#Daqui para frente serão trabalhadas as funções que são passadas através de um sinal e outras funções
#Que estão sendo chamadas anteriormente
func mudar_cor(color):
	cor = color	

func mudar_corfill(color):
	corfill = color

func _on_mouse_entered() -> void:
	AreaDesenho = true

func _on_mouse_exited() -> void:
	AreaDesenho = false

func _on_color_picker_color_changed(color: Color):
	mudar_cor(color)
	queue_redraw()

func _on_color_picker_2_color_changed(color: Color):
	mudar_corfill(color)
	queue_redraw()

func _on_button_pressed():
	if len(pontosClique)>2:
		criarPolys()
		$"../OptionButton".add_item("Polígono: " + str(i+1))
		i += 1

func trocar_cor_fill(numero):
	polys[numero]["cordentro"] = corfill
	queue_redraw()

func _on_fillpoly_pressed():
	var numero = $"../OptionButton".get_selected()
	trocar_cor_fill(numero)

func _on_remover_poly_pressed() -> void:
	var numero = $"../OptionButton".get_selected()
	if numero >= 0 and numero < polys.size():
		$"../OptionButton".remove_item(numero)
		polys.remove_at(numero)
	queue_redraw()
