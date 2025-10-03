extends Area2D
var pontosClique = []
var polys = []
var cor : Color = Color.YELLOW
var corFill : Color = Color.AQUA
var corVertice : Color = Color.BLACK
var AreaDesenho: bool
var i = 0

func _ready() -> void:
	queue_redraw()

func _input(event):
	if event.is_action_pressed("CriarPonto") and AreaDesenho:
		criarPontos()

func criarPolys():
	polys.append({"pontos": pontosClique.duplicate(), "corAresta": cor, "corDentro": corFill})
	pontosClique = []
	queue_redraw()

func criarPontos():
	var mousePos = get_local_mouse_position()
	pontosClique.append({"pos": mousePos, "color": corVertice})
	queue_redraw()

func FillPoly(poligono):
	var Ymin = null
	var Ymax = null
	var points = poligono["pontos"]

	if points.size() < 3:
		return

	for point in points:
		if Ymin == null or point.pos.y < Ymin:
			Ymin = point.pos.y
		if Ymax == null or point.pos.y > Ymax:
			Ymax = point.pos.y
	
	if Ymin == null or Ymax == null:
		return
		
	Ymin = floori(Ymin)
	Ymax = ceili(Ymax)
	
	var NsTotal = Ymax - Ymin
	if NsTotal <= 0:
		return

	# O array de interseções agora armazena dicionários: {"x": float, "color": Color}
	var intersec: Array[Array]
	intersec.resize(NsTotal)

	# Itera por todas as arestas do polígono
	for i in range(len(points)):
		var p1 = points[i]
		var p2 = points[i-1]
		
		var startPoint = p1 if p1.pos.y < p2.pos.y else p2
		var endPoint = p1 if p1.pos.y >= p2.pos.y else p2

		var dx = endPoint.pos.x - startPoint.pos.x
		var dy = endPoint.pos.y - startPoint.pos.y

		if dy != 0:
			# Variação de X por scanline (slope)
			var tx = dx / dy
			# Variação da COR por scanline
			var dColor = endPoint.color - startPoint.color
			var tColor = dColor / dy
			
			var x = startPoint.pos.x
			var color = startPoint.color

			for u in range(floori(startPoint.pos.y), floori(endPoint.pos.y)):
				var scanline_index = u - Ymin
				
				if scanline_index >= 0 and scanline_index < NsTotal:
					# Adiciona a interseção com sua posição X e COR interpolada
					intersec[scanline_index].append({"x": x, "color": color})
				
				x += tx
				color += tColor # Interpola a cor ao longo da aresta

	# Desenha as scanlines interpoladas
	var valorY = Ymin
	for scanline in intersec:
		# Ordena as interseções pela coordenada X
		scanline.sort_custom(func(a, b): return a.x < b.x)
		
		for j in range(0, len(scanline), 2):
			if j + 1 < len(scanline):
				var startIntersec = scanline[j]
				var endIntersec = scanline[j+1]
				
				var startX = startIntersec.x
				var endX = endIntersec.x
				var startColor = startIntersec.color
				var endColor = endIntersec.color
				
				var verific = endX - startX
				if verific <= 0:
					continue
				
				# Desenha a linha horizontal pixel por pixel para interpolar a cor
				for coordX in range(ceili(startX), floori(endX)):
					# Calcula o fator de interpolação (t) de 0.0 a 1.0
					var t = (coordX - startX) / verific
					# Interpola linearmente a cor (lerp)
					var pixelColor = startColor.lerp(endColor, t)
					# Desenha um retângulo de 1x1 pixel com a cor calculada
					draw_rect(Rect2(coordX, valorY, 1, 1), pixelColor, false)
		valorY += 1
		
#Função própria da Godot, para poder desenhar usando o Canvas
func _draw():
	@warning_ignore("shadowed_variable")
	for i in range(len(pontosClique)-1):
		draw_line(pontosClique[i].pos, pontosClique[i+1].pos, cor, 3.5)
	if len(pontosClique) > 1:
		draw_line(pontosClique[-1].pos, pontosClique[0].pos, cor, 3.5)
	for point in pontosClique:
		draw_circle(point.pos, 5, point.color) 
	for polig in polys:
		var points = polig["pontos"]
		var corar = polig["corAresta"]
		FillPoly(polig) 
		@warning_ignore("shadowed_variable")
		for i in range(len(points)-1):
			draw_line(points[i].pos, points[i+1].pos, corar, 3.5)
		if len(points) > 1:
			draw_line(points[-1].pos, points[0].pos, corar, 3.5)
		for point in points:
			draw_circle(point.pos, 5, point.color)

@warning_ignore("unused_parameter")
func _process(delta):
	pass
	
#Daqui para frente serão trabalhadas as funções que são passadas através de um sinal e outras funções
#Que estão sendo chamadas anteriormente
func mudar_cor(color, numero):
	# Verifica se o número do polígono selecionado é válido
	if numero >= 0 and numero < polys.size():
		polys[numero]["corAresta"] = color
		queue_redraw()
		
func mudar_corFill(color):
	corFill = color

func _on_mouse_entered() -> void:
	AreaDesenho = true

func _on_mouse_exited() -> void:
	AreaDesenho = false

func _on_color_picker_color_changed(color: Color):
	var numero = $"../OptionButton".get_selected()
	mudar_cor(color, numero)
	queue_redraw()

func _on_color_picker_2_color_changed(color: Color):
	mudar_corFill(color)
	queue_redraw()

func _on_button_pressed():
	if len(pontosClique)>2:
		criarPolys()
		$"../OptionButton".add_item("Polígono: " + str(i+1))
		i += 1

func trocar_cor_fill(numero):
	polys[numero]["corDentro"] = corFill
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

func _on_color_picker_3_color_changed(color: Color) -> void:
	mudar_corVertice(color)
	queue_redraw()
	pass # Replace with function body.
	
func mudar_corVertice(color):
	corVertice = color
	pass
