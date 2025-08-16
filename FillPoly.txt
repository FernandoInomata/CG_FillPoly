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
	for point in points:
		if ymin == null or point.y < ymin:
			ymin = point.y
		if  ymax == null or point.y > ymax:
			ymax = point.y
	ymin = floori(ymin)
	ymax = ceili(ymax)
	var NsTotal = ymax - ymin
	var intersec: Array[Array]
	var coacla = 0
	intersec.resize(abs(NsTotal))
	for i in len(points):
		var start = points[i-1]
		var end = points[i]
		if end.y < start.y:
			var temp = start
			start = end
			end = temp
		var dx = end.x - start.x
		var dy = end.y - start.y
		var tx = dx/dy
		var x = start.x
		for u in range(start.y, end.y):
			intersec[u-ymin].append(x)
			x += tx
	for scanline in intersec:
		coacla += 1
		scanline.sort()
		for j in range(0, len(scanline), 2):
			var start = scanline[j]
			var end = scanline[j+1]
			if start != end:
				var line : Vector2
				line.x = ceilf(start)
				line.y = (coacla+ymin)
				var line2: Vector2
				line2.x = floorf(end)
				line2.y = (coacla+ymin)
				draw_line(line,line2,poligono["cordentro"])

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
		$"../OptionButton".add_item("Polígono: " + str(i))
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
